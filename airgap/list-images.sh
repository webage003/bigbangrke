#!/usr/bin/env bash

# obtain all unique container / init container image paths
kubectl get pods -A -o jsonpath="{.items[*].spec['containers','initContainers'][*].image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c | awk '{ print $2 }'