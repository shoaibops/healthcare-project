data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["oneforall"]   #for exesting security group
  }
}

resource "aws_instance" "ec2-prod" {
  count = 2 # Will create 2 machines,
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t3.medium"
  key_name      = "aws-key"   # Name of the existing key pair in AWS

  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  tags = {
    Name = "k8s_docker_jenkins_master"
  }
}
