#!/bin/bash
set -ex

if [[ -n "${AIRGAP}" ]]; then
# Download rke2 images
curl -L https://github.com/rancher/rke2/releases/download/v1.18.12+rke2r2/rke2-images.linux-amd64.txt >> $IMAGE_LIST
fi