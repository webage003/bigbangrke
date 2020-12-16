#!/bin/bash

cat << EOF > "synker.yaml"
transport:
  registry:
    hostname: localhost
    port: 25000
    osChoice: linux
    disablePolicyChecks: true

options:
  # TODO: Turn this off for now until parallel syncing is more "production" ready
  # NOTE: Finding some bugs (even with retry) in pushing images to the airgapped registry that trace back to paralell syncing
  parallelSync: false
  quiet: false
  debug: info

source:
  images:
    - alpine:latest
    - nginx:latest
EOF
