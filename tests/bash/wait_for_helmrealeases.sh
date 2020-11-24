  #!/bin/bash
kubectl wait --for=condition=Ready --timeout 300s helmrelease -n bigbang \
$(kubectl get helmrelease -n bigbang | awk '{print $1}' | grep -v NAME)

kubectl wait --for=condition=Ready --timeout 30s kustomizations.kustomize.toolkit.fluxcd.io -n bigbang secrets