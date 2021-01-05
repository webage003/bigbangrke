locals {
  name = "umbrella-${var.env}"

  tags = {
    "project"   = "umbrella"
    "env"       = var.env
    "terraform" = "true"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
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
  pre_userdata = var.airgap == false ? var.pre_userdata : <<-EOF
# Temporarily disable selinux enforcing due to missing policies in containerd
# The change is currently being upstreamed and can be tracked here: https://github.com/rancher/k3s/issues/2240
setenforce 0

# Tune vm sysctl for elasticsearch
sysctl -w vm.max_map_count=262144

# Configure nodes to use proxy in most contexts
cat << EOP | tee -a /etc/environment /etc/profile /etc/sysconfig/rke2-* > /dev/null

http_proxy=http://proxy.dsop.io:8888
https_proxy=http://proxy.dsop.io:8888
HTTP_PROXY=http://proxy.dsop.io:8888
HTTPS_PROXY=http://proxy.dsop.io:8888
no_proxy=${data.aws_vpc.selected.cidr_block},10.42.0.0/16,10.43.0.0/16,localhost,127.0.0.1,169.254.169.254,.internal
NO_PROXY=${data.aws_vpc.selected.cidr_block},10.42.0.0/16,10.43.0.0/16,localhost,127.0.0.1,169.254.169.254,.internal
EOP

# Configure RKE2 with the repo1 registry
cat << EOR > /etc/rancher/rke2/registries.yaml
mirrors:
  registry.dsop.io:
    endpoint:
      - "http://registry.dsop.io:5000"
  registry1.dsop.io:
    endpoint:
      - "http://registry.dsop.io:5000"
configs:
  "registry.dsop.io":
    auth:
      username: ${var.registry_username}
      password: ${var.registry_password}
  "registry1.dsop.io":
    auth:
      username: ${var.registry_username}
      password: ${var.registry_password}
EOR
EOF

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
  pre_userdata = var.airgap == false ? var.pre_userdata : <<-EOF
# Temporarily disable selinux enforcing due to missing policies in containerd
# The change is currently being upstreamed and can be tracked here: https://github.com/rancher/k3s/issues/2240
setenforce 0

# Tune vm sysct for elasticsearch
sysctl -w vm.max_map_count=262144

# Configure nodes to use proxy in most contexts
cat << EOP | tee -a /etc/environment /etc/profile /etc/sysconfig/rke2-* > /dev/null

http_proxy=http://proxy.dsop.io:8888
https_proxy=http://proxy.dsop.io:8888
HTTP_PROXY=http://proxy.dsop.io:8888
HTTPS_PROXY=http://proxy.dsop.io:8888
no_proxy=${data.aws_vpc.selected.cidr_block},10.42.0.0/16,10.43.0.0/16,localhost,127.0.0.1,169.254.169.254,.internal
NO_PROXY=${data.aws_vpc.selected.cidr_block},10.42.0.0/16,10.43.0.0/16,localhost,127.0.0.1,169.254.169.254,.internal
EOP

# Configure RKE2 with the repo1 registry
cat << EOR > /etc/rancher/rke2/registries.yaml
mirrors:
  registry.dsop.io:
    endpoint:
      - "http://registry.dsop.io:5000"
  registry1.dsop.io:
    endpoint:
      - "http://registry.dsop.io:5000"
configs:
  "registry.dsop.io":
    auth:
      username: ${var.registry_username}
      password: ${var.registry_password}
  "registry1.dsop.io":
    auth:
      username: ${var.registry_username}
      password: ${var.registry_password}
EOR
EOF

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