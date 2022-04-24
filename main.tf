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

  root_block_device {
    volume_size = 16
  }

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
  provisioner "file" {
    source      = "download_links.sh"
    destination = "/tmp/download_links.sh"
  }
  provisioner "file" {
    source      = "vars.sh"
    destination = "/tmp/vars.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "find /tmp/ -type f \\( -iname \"*.sh\" \\) -exec sudo sed -i 's/\r$//' {} \\;",
      "export ENABLE_LOG=${var.enable_logs} && echo \"ENABLE_LOG inline $ENABLE_LOG\" && export WGET_LINK=${var.remote_links} && envsubst < /tmp/vars.sh > /tmp/variables.sh && cat /tmp/variables.sh",
      "sudo chmod +x /tmp/loop.sh /tmp/download_links.sh /tmp/vars.sh",
      "echo '*/${var.watch_repeat} * * * * sudo /tmp/download_links.sh 2>&1 &>>/tmp/download.log &' | crontab -",
      "crontab -l | { cat; echo '* ${var.shutdown_hour} * * * sudo shutdown now'; } | crontab -",
      "sudo nohup bash /tmp/loop.sh ${var.attack_duration} 2>&1 &> /tmp/logs.out &", 
      "sleep 5 && echo 'loop started' && ps aux | grep [l]oop",
      "disown -a",
      "echo 'remote-exec completed'"
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
