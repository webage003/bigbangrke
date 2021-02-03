# Temporarily disable selinux enforcing due to missing policies in containerd
# The change is currently being upstreamed and can be tracked here: https://github.com/rancher/k3s/issues/2240
setenforce 0

# Tune vm sysctl for elasticsearch
sysctl -w vm.max_map_count=262144

# Configure nodes to use proxy in most contexts
cat << EOP | tee -a /etc/environment /etc/profile /etc/sysconfig/rke2-* > /dev/null

http_proxy=http://proxy.dso.mil:8888
https_proxy=http://proxy.dso.mil:8888
HTTP_PROXY=http://proxy.dso.mil:8888
HTTPS_PROXY=http://proxy.dso.mil:8888
no_proxy=${cidr_block},10.42.0.0/16,10.43.0.0/16,localhost,127.0.0.1,169.254.169.254,.internal
NO_PROXY=${cidr_block},10.42.0.0/16,10.43.0.0/16,localhost,127.0.0.1,169.254.169.254,.internal
EOP

# Configure RKE2 with the repo1 registry
cat << EOR > /etc/rancher/rke2/registries.yaml
mirrors:
  registry.dso.mil:
    endpoint:
      - "http://registry.dso.mil:5000"
  registry1.dso.mil:
    endpoint:
      - "http://registry1.dso.mil:5000"
configs:
  "registry.dso.mil:5000":
    auth:
      username: ${registry_username}
      password: ${registry_password}
  "registry1.dso.mil:5000":
    auth:
      username: ${registry_username}
      password: ${registry_password}
EOR

#Clone Current Repo