# Zarf Deployment

This package deploys Airgap Big Bang Core using Zarf

## Instructions

### Part 1. On your Internet facing virtual machine.

#### Pull down the code and binaries

'''shell
# git clone the latest tag.
git clone --depth 1 --branch v0.23.1 https://github.com/defenseunicorns/zarf
# change directory ( cd into zarf dir)
cd zarf
# change directory.
cd packages/big-bang-core
# pull down zarf init package.
curl -LO https://github.com/defenseunicorns/zarf/releases/download/v0.23.1/zarf-init-amd64-v0.23.1.tar.zst
# pull down zarf binary.
curl -LO https://github.com/defenseunicorns/zarf/releases/download/v0.23.1/zarf_v0.23.1_Linux_amd64
# configuration to run zarf command.
cp zarf_v0.23.1_Linux_amd64 /usr/local/bin/zarf
chmod +x /usr/local/bin/zarf
'''

#### Build the deploy package

'''shell
#change directory
cd packages/big-bang-core

# Authenticate to the registry with Big Bang artifacts ( replace your username and password).
set +o history
export REGISTRY1_USERNAME=<REPLACE_ME>
export REGISTRY1_PASSWORD=<REPLACE_ME>
echo $REGISTRY1_PASSWORD | zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history

# Run zarf package command.
zarf package create . --confirm
##this step get all images and git repo

#### copy zarf to offline virtual machine

### Part 2. On to AirGap virtual machine

#### Walk Through Prerequisites:
#Have the Zarf package that has Zarf binary, Zarf init-package, and zarf-package-big-bang-core-demo-amd64.tar.zst in the same location (directory: zarf/packages/big-bang-core).
#Have a kubernetes cluster running/available (ex. k3s/k3d/Kind).
#You have kubectl installed: (kubectl Install Instructions).
#Check to see if the cluster is ready.
kubectl get pods -A

#### configuration to run zarf command on AirGap  virtual machine
'''shell
cp zarf_v0.22.2_Linux_amd64 /usr/local/bin/zarf
chmod +x /usr/local/bin/zarf
'''

#### Initialize Zarf
# change directory
cd zarf/packages/big-bang-core
zarf init
# Make these choices at the prompt
# ? Deploy this Zarf package? Yes
# ? Deploy the k3s component? No
# ? Deploy the logging component? No
# ? Deploy the git-server component? Yes
 
#Inspect the results.
kubectl get po -A

#### Deploy Big Bang
# Deploy Big Bang (lightweight version)
'''shell
cd ../packages/big-bang-core
zarf package deploy --confirm $(ls -1 zarf-package-big-bang-core-demo-*.tar.zst) --components big-bang-core-limited-resources
# NOTE: to deploy the standard full set of components use the flag:
# '--components big-bang-core-standard'


Inspect the results
kubectl get po -A
'''

### Part 3. Deploy addons

#### Modify zarf.yaml to collect all require images. zarf.yaml directory is in /zarf/packages/big-bang-core. We are using gitlab as an example

'''shell
cd ../packages/big-bang-core

  - name: big-bang-core-gitlab-assets
    description: "Git repositories and OCI images used by gitlab"
    required: true
    repos:
      - https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/gitlab@6.5.2-bb.2
    images:
      - registry1.dso.mil/ironbank/gitlab/gitlab/kubectl:15.5.2
      - registry1.dso.mil/ironbank/redhat/ubi/ubi8:8.7
      - registry1.dso.mil/ironbank/bitnami/analytics/redis-exporter:v1.45.0
      - registry1.dso.mil/ironbank/bitnami/redis:7.0.0-debian-10-r3
      - registry1.dso.mil/ironbank/opensource/postgres/postgresql12:12.13
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-container-registry:15.5.2
      - registry1.dso.mil/ironbank/gitlab/gitlab/cfssl-self-sign:1.6.1
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox:15.5.2
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-exporter:15.5.2
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-sidekiq:15.5.2
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-shell:15.5.2
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-mailroom:15.5.2
      - registry1.dso.mil/ironbank/gitlab/gitlab/gitaly:15.5.2
      - registry1.dso.mil/ironbank/opensource/minio/minio:RELEASE.2022-11-11T03-44-20Z
      - registry1.dso.mil/ironbank/opensource/minio/mc:RELEASE.2022-11-07T23-47-39Z
      - registry1.dso.mil/ironbank/gitlab/gitlab/alpine-certificates:15.5.2
'''

#### Modify values.yaml to add gitlab. values.yaml directory is in /zarf/packages/big-bang-core/kustomization/core-standard

'''shell
addons:
  gitlab:
    enabled: true
'''

#### Run zarf package command
'''shell
zarf package create . --confirm
# Copy new zarf package to offline virtual machine
'''

#### Initialize zarf

'''shell
# change directory.
cd zarf/packages/big-bang-core
zarf init
# Make these choices at the prompt
# ? Deploy this Zarf package? Yes
# ? Deploy the k3s component? No
# ? Deploy the logging component? No
# ? Deploy the git-server component? Yes
 
# Inspect the results
kubectl get po -A
'''

#### Deploy Big Bang

'''shell
# Deploy Big Bang (lightweight version)
cd ../packages/big-bang-core
zarf package deploy --confirm $(ls -1 zarf-package-big-bang-core-demo-*.tar.zst) --components big-bang-core-limited-resources
# NOTE: to deploy the standard full set of components use the flag:
# '--components big-bang-core-standard'

NOTE: check to see if gitlab is running
'''

### Part 4. Useful zarf troubleshooting

'''shell
# List packages 
    zarf package list
   zarf package —help

#  Remove packages 
   zarf package remove big-bang-core-demo
   zarf package remove big-bang-core-demo —confirm

# nuke the installation 
   zarf destroy
    zarf destroy  —confirm

# Redeploy 
    zarf init
   zarf package deploy
'''

# Link to official Zarf repo [Big Bang Core](https://github.com/defenseunicorns/zarf/tree/main/packages/big-bang-core)





