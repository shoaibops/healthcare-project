provider "aws" {
  region = "ap-south-1"
}

data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["oneforall"]
  }
}
