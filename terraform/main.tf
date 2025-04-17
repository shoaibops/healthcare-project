provider "aws" {
  region = "ap-south-1"
}

# Create a new security group for the EC2 instances
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-security-group"
  description = "Security group for Kubernetes nodes"
  vpc_id      = "vpc-id"  # Replace with your VPC ID

  ingress {
    from_port   = 22    # Allow SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs for SSH (you can restrict this)
  }

  ingress {
    from_port   = 6443  # Allow Kubernetes API Server port
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (you can restrict this)
  }

  ingress {
    from_port   = 2379  # Allow etcd port
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# EC2 Instances for Kubernetes
resource "aws_instance" "k8s-node" {
  count         = 2
  ami           = "ami-0e35ddab05955cf57"  # Change to the AMI of your choice
  instance_type = "t3.medium"
  key_name      = "aws-key"  # Make sure this matches your key name

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]  # Use the new security group

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
}

output "k8s_instances_ips" {
  value = aws_instance.k8s-node[*].private_ip
}
