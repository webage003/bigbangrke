variable "aws_region" {
  type    = string
  default = "us-gov-west-1"
}

variable "key_name" {
  type        = string
  default     = "bigbang-dev-shared"
  description = "checkout Secrets Manager"
}

variable "subnet_id" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_root_block_size" {
  default = 100
}

variable "vpc_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "utility_username" {
  type    = string
  description = "Username of the docker utility, this will be generated randomly if left empty."
  default = ""
}

variable "utility_password" {
  type    = string
  description = "Password of the docker utility, this will be generated randomly if left empty."
  default = ""
}
