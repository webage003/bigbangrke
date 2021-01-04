output "vpc_cidr" {
  value = data.aws_vpc.selected.cidr_block
}