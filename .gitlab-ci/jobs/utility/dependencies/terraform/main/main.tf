locals {
  name = "umbrella-${var.env}-utility"
  utility_username = var.utility_username != "" ? var.utility_username : random_string.utility_username.result
  utility_password = var.utility_password != "" ? var.utility_password : random_password.utility_password.result
  tags = {
    "terraform"       = "true",
    "env"             = var.env,
    "project"         = "umbrella",
    "ci_pipeline_url" = var.ci_pipeline_url
  }
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
  tags = local.tags
}

resource "aws_route53_zone" "dso" {
  name = "dso.mil"

  vpc {
    vpc_id = data.aws_vpc.vpc_id.id
  }
  tags = local.tags
}

# Registry
resource "aws_route53_record" "dsop_registry" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "registry.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dso_registry" {
  zone_id = aws_route53_zone.dso.zone_id
  name    = "registry.dso.mil"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dsop_registry1" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "registry1.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dso_registry1" {
  zone_id = aws_route53_zone.dso.zone_id
  name    = "registry1.dso.mil"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}


#Repository
resource "aws_route53_record" "dsop_repository" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "repository.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dso_repository" {
  zone_id = aws_route53_zone.dso.zone_id
  name    = "repository.dso.mil"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dsop_repo1" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "repo1.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dso_repo1" {
  zone_id = aws_route53_zone.dso.zone_id
  name    = "repo1.dso.mil"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}


#Proxy

resource "aws_route53_record" "dsop_proxy" {
  zone_id = aws_route53_zone.dsop.zone_id
  name    = "proxy.dsop.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.utility.private_ip]
}

resource "aws_route53_record" "dso_proxy" {
  zone_id = aws_route53_zone.dso.zone_id
  name    = "proxy.dso.mil"
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
    vpc_cidr         = data.aws_vpc.vpc_id.cidr_block
    pkg_s3_bucket    = var.pkg_s3_bucket
    pkg_path         = var.pkg_path
    aws_region       = var.aws_region
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

  tags = merge({
    "Name" = "allow_utility"
  }, local.tags)
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

  ingress {
    description = "Allow access to git repository"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    "Name" = "allow_repository"
  }, local.tags)
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
  
  tags = merge({
    "Name" = "allow_proxy"
  }, local.tags)
}

# aws instance to create and provision
resource "aws_instance" "utility" {
  instance_type   = var.instance_type
  ami             = data.aws_ami.utility.id
  key_name        = var.key_name
  subnet_id       = var.subnet_id
  vpc_security_group_ids = [aws_security_group.allow_utility.id, aws_security_group.allow_repository.id, aws_security_group.allow_proxy.id]
  user_data       = data.template_file.init.rendered
  iam_instance_profile = aws_iam_instance_profile.utility.name
  root_block_device {
    volume_size = var.aws_root_block_size
  }

  tags = merge({
    "Name"  = local.name,
    "Owner" = basename(data.aws_caller_identity.current.arn)
  }, local.tags)

}

