variable "region" {
  default = "us-east-1"
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "public_key_location" {
  description = "Location to SSH public key"
}

variable "domain" {
  description = "AWS Route53 domain"
}

variable "ecs_ami" {
  default = {
    us-east-1 = "ami-07fde2ae86109a2af"
    us-west-2 = "ami-0b89310f457a9e90e"
  }
}