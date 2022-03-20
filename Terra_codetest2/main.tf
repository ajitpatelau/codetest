terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Creating webserver inside the public subnet

resource "aws_instance" "web_instance" {
    ami                         = var.ami
    associate_public_ip_address = true
    instance_type               = var.instance_type
    key_name                    = "jenkin"
    vpc_security_group_ids      = [aws_security_group.websg.id]
    subnet_id                   = aws_subnet.subnets[0].id
    
    tags = {
      Name = "webserver"

    }
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.web_instance.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.web_instance.public_ip}, --private-key ${local.private_key_path} apache.yml"
  }
}

# Creating dadabase server inside the private subnet
resource "aws_instance" "db_instance" {
    ami                         = var.ami
    associate_public_ip_address = false
    instance_type               = var.instance_type
    key_name                    = "jenkin"
    vpc_security_group_ids      = [aws_security_group.dbsg.id]
    subnet_id                   = aws_subnet.subnets[1].id

    tags = {
      Name = "database"
    }
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.db_instance.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.db_instance.public_ip}, --private-key ${local.private_key_path} mysql_role.yml"
  }
}

locals {
  anywhere         = "0.0.0.0/0"
  ssh_port         = 22
  http_port        = 80
  https_port       = 443
  mysql_port       = 3306
  tcp              = "TCP"
  ssh_user         = "ubuntu"
  key_name         = "jenkin"
  private_key_path = "~/playbooks/jenkin.pem"
}


