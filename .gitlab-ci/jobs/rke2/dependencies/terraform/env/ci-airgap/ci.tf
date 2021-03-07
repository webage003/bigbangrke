terraform {
  backend "s3" {
    bucket               = "umbrella-tf-states"
    key                  = "terraform.tfstate"
    region               = "us-gov-west-1"
    dynamodb_table       = "umbrella-tf-states-lock"
    workspace_key_prefix = "rke2"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket               = "umbrella-tf-states"
    key                  = "terraform.tfstate"
    region               = "us-gov-west-1"
    workspace_key_prefix = "aws-networking"
  }
  workspace = var.env
}

data "aws_vpc" "selected" {
  id = data.terraform_remote_state.networking.outputs.vpc_id
}


data "terraform_remote_state" "utility" {
  backend = "s3"
  config = {
    bucket               = "umbrella-tf-states"
    key                  = "terraform.tfstate"
    region               = "us-gov-west-1"
    workspace_key_prefix = "utility"
  }
  workspace = var.env
}

module "ci" {
  source = "../../main"

  env                 = var.env
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  deploy_subnets      = data.terraform_remote_state.networking.outputs.intra_subnets
  public_subnets      = data.terraform_remote_state.networking.outputs.public_subnets
  server_ami          = "ami-0bf477482e4fd17b3"
  agent_ami           = "ami-06752d8b8e52b1336"
  airgap              = true
  download            = false
  registry_username   = data.terraform_remote_state.utility.outputs.utility_username
  registry_password   = data.terraform_remote_state.utility.outputs.utility_password
}