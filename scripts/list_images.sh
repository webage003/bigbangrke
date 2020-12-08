#!/usr/bin/env bash

# obtain all unique container / init container image paths
# TODO - Make sure this is all the images
kubectl get all -A -o jsonpath="{.items[*].spec['containers','initContainers'][*].image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c | awk '{ print $2 }'