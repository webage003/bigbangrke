#!/bin/bash
set -ex

# Deploy flux and wait for it to be ready
echo "Installing Flux"
kubectl apply -f https://repo1.dsop.io/platform-one/big-bang/apps/sandbox/fluxv2/-/raw/master/flux-system.yaml
flux check

# Deploy BigBang using dev sized scaling
echo "Installing BigBang"
helm upgrade -i bigbang chart -n bigbang --create-namespace \
  --set registryCredentials.username='robot$bigbang' --set registryCredentials.password=${REGISTRY1_PASSWORD} \
  -f tests/ci/k3d/values.yaml

## Apply secrets kustomization pointing to current branch
echo "Deploying secrets from the ${CI_COMMIT_REF_NAME} branch"
cat tests/ci/shared-secrets.yaml | sed 's|master|'$CI_COMMIT_REF_NAME'|g' | kubectl apply -f -
