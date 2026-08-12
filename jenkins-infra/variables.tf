variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.large"   # Sonar+ES+Jenkins need the RAM; smaller will swap/OOM
}
