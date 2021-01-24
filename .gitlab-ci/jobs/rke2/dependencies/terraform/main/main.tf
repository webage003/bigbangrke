locals {
  name = "umbrella-${var.env}"

  tags = {
    "project"         = "umbrella"
    "env"             = var.env
    "terraform"       = "true",
    "ci_pipeline_url" = var.ci_pipeline_url
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "template_file" "airgap_userdata" {
  template = file("${path.module}/templates/airgap_userdata.tpl")
  vars = {
     registry_username = var.registry_username
     registry_password = var.registry_password
     cidr_block   = data.aws_vpc.selected.cidr_block
  }
}

data "template_file" "nonairgap_userdata" {
  template = file("${path.module}/templates/nonairgap_userdata.tpl")
}


module "rke2" {
  source = "git::https://github.com/rancherfederal/rke2-aws-tf.git"

  cluster_name          = local.name
  vpc_id                = data.aws_vpc.selected.id
  subnets               = var.deploy_subnets
  ami                   = var.server_ami
  servers               = var.servers
  instance_type         = var.server_instance_type
  ssh_authorized_keys   = var.ssh_authorized_keys
  controlplane_internal = var.controlplane_internal
  rke2_version          = var.rke2_version

  enable_ccm = var.enable_ccm
  download   = var.download

  rke2_config = <<-EOF
# kube-apiserver-arg:
# - "--runtime-config=settings.k8s.io/v1alpha1=true"
# - "--enable-admission-plugins=PodPreset"
EOF

  # TODO: These need to be set in pre-baked ami's
  pre_userdata = var.airgap == false ? data.template_file.nonairgap_userdata.rendered : data.template_file.airgap_userdata.rendered

  tags = merge({}, local.tags, var.tags)
}

module "generic_agents" {
  source = "git::https://github.com/rancherfederal/rke2-aws-tf.git//modules/agent-nodepool"

  name                = "generic-agent"
  vpc_id              = data.aws_vpc.selected.id
  subnets             = var.deploy_subnets
  ami                 = var.agent_ami
  asg                 = var.agent_asg
  spot                = var.agent_spot
  instance_type       = var.agent_instance_type
  ssh_authorized_keys = var.ssh_authorized_keys
  rke2_version        = var.rke2_version

  enable_ccm        = var.enable_ccm
  enable_autoscaler = var.enable_autoscaler
  download          = var.download

  rke2_config = <<-EOF
# kube-apiserver-arg:
# - "--runtime-config=settings.k8s.io/v1alpha1=true"
# - "--enable-admission-plugins=PodPreset"
EOF

  # TODO: These need to be set in pre-baked ami's
  pre_userdata = var.airgap == false ? data.template_file.nonairgap_userdata.rendered : data.template_file.airgap_userdata.rendered

  # Required data for identifying cluster to join
  cluster_data = module.rke2.cluster_data

  tags = merge({}, local.tags, var.tags)
}

# Example method of fetching kubeconfig from state store, requires aws cli
resource "null_resource" "kubeconfig" {
  depends_on = [module.rke2]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "aws s3 cp ${module.rke2.kubeconfig_path} rke2.yaml"
  }
}

## Adding tags on VPC and Subnets to match uniquely created cluster name
resource "aws_ec2_tag" "vpc_tags" {
  resource_id = data.aws_vpc.selected.id
  key         = "kubernetes.io/cluster/${module.rke2.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_subnets_tags" {
  count       = length(var.public_subnets)
  resource_id = var.public_subnets[count.index]
  key         = "kubernetes.io/cluster/${module.rke2.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "deploy_subnets_tags" {
  count       = length(var.deploy_subnets)
  resource_id = var.deploy_subnets[count.index]
  key         = "kubernetes.io/cluster/${module.rke2.cluster_name}"
  value       = "shared"
}