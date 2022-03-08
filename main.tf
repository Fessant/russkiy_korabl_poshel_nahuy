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
  region  = var.aws_region
}

resource "aws_spot_instance_request" "app_server" {
  ami                    = lookup(var.ami, var.aws_region)
  count                  = var.instance_count
  instance_type          = var.instance_type
  spot_price             = 0.1
  wait_for_fulfillment   = true
  spot_type              = "one-time"
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "Terraform-${count.index + 1}"
  }

  provisioner "file" {
    source      = "links.txt"
    destination = "/tmp/links.txt"
  }
  provisioner "file" {
    source      = "loop.sh"
    destination = "/tmp/loop.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "file /tmp/loop.sh | grep 'CRLF' && sudo vim /tmp/loop.sh -c 'set ff=unix' -c ':wq'",
      "sudo chmod +x /tmp/loop.sh",
      "sudo bash /tmp/loop.sh ${var.attack_duration} ${var.enable_logs} ${var.remote_links}"
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
