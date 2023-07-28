terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.63.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

locals {
  VMsizes = toset([
    "t2.nano",
    "t2.micro",
    "t2.large",
  ])
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "search_for_key_pair" {}

resource "aws_instance" "VMka" {
  for_each = local.VMsizes
  instance_type = each.key
  ami = data.aws_ami.ubuntu.id
  key_name = data.aws_key_pair.search_for_key_pair.key_name

  tags = {
    name = "${each.key}"
}
}
import {
  to = aws_instance.VMka["t2.large"]
  id = "i-069cc3545f129f365"
}
