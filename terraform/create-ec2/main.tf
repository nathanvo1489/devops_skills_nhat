provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  # create more machines for ansible playbook
  count = 2

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "devops"

  # # Run on 1st creation only
  # vpc_security_group_ids = [
  #   aws_security_group.terraform_sg.id
  # ]

  # Map existing security group to the new instances, from 2nd run onwards, to avoid creating a new security group every time
  vpc_security_group_ids = [
    data.aws_security_group.existing.id
  ]

  # create more machines for ansible playbook
  tags = {
    Name = "terraform-ec2-${count.index + 1}"
  }
}

# Existing security group, from 2nd run onwards, to avoid creating a new security group every time
data "aws_security_group" "existing" {
  id = "sg-0fd733980fe0ad2fb"
}

# Run on 1st creation only
# resource "aws_security_group" "terraform_sg" {
#   name = "terraform-ec2-sg"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

output "public_ip" {
  value = aws_instance.app_server[*].public_ip
}