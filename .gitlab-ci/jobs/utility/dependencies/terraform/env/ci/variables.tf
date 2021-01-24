variable "ssh_ip_block" {
  type    = string
  description = "IP Block that can access this instance via ssh"
  default = "0.0.0.0/0"
}
variable "env" {}

variable "pkg_s3_bucket" {
  type    = string
  description = "S3 Bucket where the packages are stored."
}

variable "pkg_path" {
  type    = string
  description = "The Path in the bucket to locate the package ."
}

variable "ci_pipeline_url" {}