output "utility_ip" {
  value = aws_instance.utility.private_ip
}

output "utility_username" {
  value = local.utility_username
}

output "utility_password" {
  value = local.utility_password
}
