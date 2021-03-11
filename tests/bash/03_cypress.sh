#!/usr/bin/env bash

# exit on error
set -ex

mkdir -p cypress-tests/

#Cloning core
for i in $( grep -r "addons:" tests/ci/k3d/values.yaml -B 100 | grep "enabled: true" -B 1 | grep -v "enabled: true" | sed -e 's/:.*//' | sed 's/^ *//g' | sed 's/--//' | grep . )
do
    git -C cypress-tests/ clone -b $(yq r "chart/values.yaml" "${i}.git.tag") $(yq r "chart/values.yaml" "${i}.git.repo")
done

#Cloning addons
for i in $( grep -r "addons:" tests/ci/k3d/values.yaml -A 100 | grep "enabled: true" -B 1 | grep -v "enabled: true" | sed -e 's/:.*//' | sed 's/^ *//g' | sed 's/--//' | grep . )
do
    git -C cypress-tests/ clone -b $(yq r "chart/values.yaml" "addons.${i}.git.tag") $(yq r "chart/values.yaml" "addons.${i}.git.repo")
done

#Running Cypress tests
for dir in cypress-tests/*/
do
  if [ -f "${dir}tests/cypress.json" ]; then
    cypress run --project ${dir}tests
  fi
done