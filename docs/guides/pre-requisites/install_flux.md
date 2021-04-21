# Install the flux cli tool

```bash
sudo curl -s https://toolkit.fluxcd.io/install.sh | sudo bash
```
>   Fedora Note: kubectl is a prereq for flux, and flux expects it in `/usr/local/bin/kubectl` symlink it or copy the binary to fix errors.

## Install flux.yaml to the cluster
```bash
export REGISTRY1_USER='REPLACE_ME'
export REGISTRY1_TOKEN='REPLACE_ME'
```
> In production use robot credentials, single quotes are important due to the '$'  
`export REGISTRY1_USER='robot$bigbang-onboarding-imagepull'`


```bash
kubectl create ns flux-system
kubectl create secret docker-registry private-registry \
    --docker-server=registry1.dso.mil \
    --docker-username=$REGISTRY1_USER \
    --docker-password=$REGISTRY1_TOKEN \
    --namespace flux-system
kubectl apply -f https://repo1.dso.mil/platform-one/big-bang/bigbang/-/raw/master/scripts/deploy/flux.yaml
```
>   k apply -f flux.yaml, is equivalent to "flux install", but it installs a version of flux that's been tested and gone through IronBank.


#### Now you can see new CRD objects types inside of the cluster
```bash
kubectl get crds | grep flux
```
