############################
# variables.tf
############################
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.32.0.0/16"
}

variable "cluster_name" {
  type    = string
  default = "test-app-cluster"
}

variable "docker_image_tag" {
  type    = string
  default = "latest"
}

variable "user_name" {
  type    = string
  default = "web-app-terraform"
}
