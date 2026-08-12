variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "boi-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "services" {
  type    = list(string)
  default = ["boi-api-gateway", "boi-auth-service", "boi-account-service", "boi-transaction-service"]
}
