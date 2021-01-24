# Temporarily disable selinux enforcing due to missing policies in containerd
# The change is currently being upstreamed and can be tracked here: https://github.com/rancher/k3s/issues/2240
setenforce 0

# Tune vm sysctl for elasticsearch
sysctl -w vm.max_map_count=262144
