variable "vpc_cidr" {}
variable "env" {}
variable "ci_pipeline_url" {}
variable "enable_spoke_intranets" {
  type = bool
  default = false
}