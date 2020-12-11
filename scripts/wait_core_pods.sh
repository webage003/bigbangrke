#!/usr/bin/env bash

# wait for core pods to come up in kube-system

set -e

for i in {1..10}; do
    kubectl wait --for=condition=Ready -n kube-system $(kubectl get po -A -o name) &>/dev/null && break || sleep 5
done

kubectl wait --for=condition=Ready -n kube-system $(kubectl get po -A -o name)