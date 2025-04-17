resource "aws_instance" "ec2-prod" {
  count         = 2
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t3.medium"
  key_name      = "aws-key"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
}
