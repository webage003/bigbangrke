locals {
  name = "umbrella-${var.env}-utility"
  utility_username = var.utility_username != "" ? var.utility_username : random_string.utility_username.result
  utility_password = var.utility_password != "" ? var.utility_password : random_password.utility_password.result
}

data "aws_ami" "utility" {
  owners      = ["self"]
  most_recent = true
  filter {
    name = "name"
    values = ["tf-k3d-bigbang"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc_id" {
  id = var.vpc_id
}

resource "aws_route53_zone" "dsop" {
  name = "dsop.io"

  vpc {
    vpc_id = data.aws_vpc.vpc_id.id
  }
}

resource "aws_route53_record" "registry" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "registry.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "repository" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "repository.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "proxy" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "proxy.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "random_string" "utility_username" {
  length  = 8
  special = false
}

resource "random_password" "utility_password" {
  length  = 16
  special = false
}

#userdata for docker utility
data "template_file" "init" {
  template = file("${path.module}/templates/utility.tpl")
  vars = {
    utility_username = local.utility_username
    utility_password = local.utility_password
  }
}

resource "aws_security_group" "allow_utility" {
  name        = "allow_utility"
  description = "Allow Access To utility"
  vpc_id      = var.vpc_id
  
  ingress {
      description = "Allow ssh access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.vpc_id.cidr_block] #only allow connection from VPC
  }
  
  #allow access from docker registry
  ingress {
    description = "Allow access to docker registry"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_id.cidr_block] #only allow connection from VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_registry"
  }
}

resource "aws_security_group" "allow_repository" {
  name        = "allow_repository"
  description = "Allow Access To Git Repository"
  vpc_id      = var.vpc_id
  
  #allow access to git repository
  ingress {
    description = "Allow access to git repository"
    from_port   = 5005
    to_port     = 5005
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_repository"
  }
}

resource "aws_security_group" "allow_proxy" {
  name        = "allow_proxy"
  description = "Allow Access To Tiny Proxy"
  vpc_id      = var.vpc_id
  
  #allow access to proxy
  ingress {
    description = "Allow access to Tiny Proxy"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_repository"
  }
}

# aws instance to create and provision
resource "aws_instance" "utility" {
  instance_type   = var.instance_type
  ami             = data.aws_ami.utility.id
  key_name        = var.key_name
  subnet_id       = var.subnet_id
  vpc_security_group_ids = [aws_security_group.allow_utility.id, aws_security_group.allow_repository.id, aws_security_group.allow_proxy.id]
  user_data       = data.template_file.init.rendered
  tags = {
    Name  = local.name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
  root_block_device {
    volume_size = var.aws_root_block_size
  }
}

