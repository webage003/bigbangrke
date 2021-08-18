# Local deploy of Big Bang on k3d

First make sure you have the tools you need installed locally: 

- `k3d`
- `helm`
- (what else??? I already had a bunch of stuff installed so I'm not sure what was already there that this depends on)

```shell
# clone the repo
git clone https://repo1.dso.mil/platform-one/big-bang/bigbang.git

# cd into the new directory
cd bigbang

# EFK needs this if you are on Linux. Otherwise you can skip to the next command
sudo sysctl -w vm.max_map_count=262144

# Create a k8s cluster with k3d using the same config that they use in the CI pipeline:
k3d cluster create -c tests/ci/k3d/config.yaml

# Get your username and password from https://registry1.dso.mil and set them as env vars to be used later.
# The password to use is in your user profile under 'CLI secret'. If you don't have an account you can
# register one on the Platform One login page.
export REGISTRY1_USERNAME="bobbytables"
export REGISTRY1_PASSWORD="yourpasswordhere"

# Deploy Flux to your new k3d cluster using your Registry1 creds
scripts/install_flux.sh -u ${REGISTRY1_USERNAME} -p ${REGISTRY1_PASSWORD}

# Create a local, gitignored file that will be passed into the cluster for registry credentials
cat <<EOF >>ignore/credentials.yaml
registryCredentials:
- registry: registry1.dso.mil
  username: ${REGISTRY1_USERNAME}
  password: ${REGISTRY1_PASSWORD}
- registry: registry1.dsop.io
  username: ${REGISTRY1_USERNAME}
  password: ${REGISTRY1_PASSWORD}
EOF

# Deploy Big Bang, using a hierarchial set of values files, with later values overwriting earlier ones
# (if present). The baseline is the same set of values Big Bang uses in the CI pipeline, then we tweak
# resources so it runs on a local developer machine, apply our gitignored credentials file, and apply
# certificates so we can use https://*.bigbang.dev (which actually is set up to forwart to localhost).
helm upgrade -i bigbang chart --create-namespace -n bigbang -f tests/ci/k3d/values.yaml -f tests/local/values.yaml -f ignore/credentials.yaml -f chart/ingress-certs.yaml
```

That's it! It will take several minutes for Flux to deploy everything, then you should be able to navigate to URLs like [https://grafana.bigbang.dev](https://grafana.bigbang.dev), which through the power of DNS forwarding and magical pixie dust is actually hitting your localhost instead of a server on the internet.