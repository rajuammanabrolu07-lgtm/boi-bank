# ---- who am I (restrict web UIs to my current public IP) ----
data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}
locals {
  my_cidr = "${chomp(data.http.myip.response_body)}/32"
}

# ---- put the build server in the DEFAULT vpc (stable, survives EKS destroy) ----
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ---- latest Amazon Linux 2023 AMI ----
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ---- security group: Jenkins 8080 + Sonar 9000 to MY ip only, no SSH ----
resource "aws_security_group" "jenkins" {
  name        = "boi-jenkins-sg"
  description = "Jenkins + Sonar web UIs to my IP only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }
  ingress {
    description = "SonarQube UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "boi-jenkins-sg" }
}

# ---- IAM role: SSM (shell) + ECR (push images) ----
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "jenkins" {
  name               = "boi-jenkins-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_instance_profile" "jenkins" {
  name = "boi-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

# ---- bootstrap: install docker, compose, kubectl; tune for Sonar ----
locals {
  user_data = <<-BASH
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y docker git
    systemctl enable --now docker
    usermod -aG docker ec2-user
    usermod -aG docker ssm-user || true

    # docker compose v2 plugin
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # kubectl (for deploying to EKS in Phase 6)
    curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
    install -m 0755 kubectl /usr/local/bin/kubectl

    # SonarQube/Elasticsearch requirement
    sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
  BASH
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = true
  user_data                   = local.user_data

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  tags = { Name = "boi-jenkins" }
}
