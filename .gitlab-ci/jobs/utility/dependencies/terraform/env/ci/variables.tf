variable "ssh_ip_block" {
  type    = string
  description = "IP Block that can access this instance via ssh"
  default = "0.0.0.0/0"
}
variable "env" {}