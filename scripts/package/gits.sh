#!/bin/bash
set -ex

mkdir -p repos/

# Clone core
yq r "chart/values.yaml" "*.git.repo" | while IFS= read -r repo; do
    git -C repos/ clone --no-checkout $repo
done

# Clone packages
yq r "chart/values.yaml" "addons.*.git.repo" | while IFS= read -r repo; do
    git -C repos/ clone --no-checkout $repo
done

if [ -n "${AIRGAP}" ]; then
   git -C repos/ clone --branch ${CI_MERGE_REQUEST_SOURCE_BRANCH_NAME} --no-checkout ${CI_REPOSITORY_URL}
fi
