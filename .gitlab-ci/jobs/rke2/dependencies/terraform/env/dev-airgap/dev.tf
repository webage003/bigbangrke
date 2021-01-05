provider "aws" {
  region = "us-gov-west-1"
}

data "terraform_remote_state" "networking" {
  backend = "local"
  config = {
    path = "../../../../../networking/aws/dependencies/terraform/env/dev/terraform.tfstate"
  }
}

data "terraform_remote_state" "utility" {
  backend = "local"
  config = {
    path = "../../../../../utility/dependencies/terraform/env/dev/terraform.tfstate"
  }
}

# Private Key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pem" {
  filename        = "rke2.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

module "dev" {
  source = "../../main"

  env      = "ismail-dev"
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  deploy_subnets      = data.terraform_remote_state.networking.outputs.intra_subnets
  public_subnets      = data.terraform_remote_state.networking.outputs.public_subnets
  ssh_authorized_keys = [tls_private_key.ssh.public_key_openssh]

  download   = false
  server_ami = "ami-00aab2121681e4a31"
  agent_ami  = "ami-00aab2121681e4a31"

  registry_username = data.terraform_remote_state.utility.outputs.utility_username
  registry_password = data.terraform_remote_state.utility.outputs.utility_password
  airgap            = var.airgap
}
