terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
}

resource "aws_security_group_rule" "monitor_ports" {
  for_each          = toset(var.sec_ports)
  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  security_group_id = var.sec_gid
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_key_pair" "deployer" {
  key_name   = "ansible-deployer-key"
  public_key = file("/var/lib/jenkins/.ssh/id_rsa.pub")
}

data "aws_ami" "image-ubuntu" {
    filter {
      name   = "name"
      values = ["ubuntu/images/*ubuntu*22.04-amd64-server-*"]
    }

    filter {
      name   = "root-device-type"
      values = ["ebs"]
    }

    filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
}

resource "aws_instance" "monitor" {
  count         = var.ec2_count

  ami           = data.aws_ami.image-ubuntu.id
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"

  tags = {
    Name    = (count.index==0 ? "main" : "exporter-${count.index}")
    Group   = (count.index==0 ? "main" : "exporter")
    Project = "JRMonitor"
  }
}

