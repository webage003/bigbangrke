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
    - registry.dsop.io/platform-one/big-bang/apps/core/monitoring/kiwigrid/k8s-sidecar:1.1.0
    - registry.dsop.io/platform-one/big-bang/apps/sandbox/authservice:redis-beta2
    - registry1.dsop.io/ironbank/opensource/coreos/kube-state-metrics:v1.9.7
    - registry1.dsop.io/ironbank/opensource/coreos/prometheus-config-reloader:v0.42.1
    - registry1.dsop.io/ironbank/opensource/coreos/prometheus-operator:v0.42.1
    - registry1.dsop.io/ironbank/opensource/fluent/fluent-bit:1.6.3
    - registry1.dsop.io/ironbank/opensource/grafana/grafana:7.1.3-1
    - registry1.dsop.io/ironbank/opensource/istio/operator:1.7.3
    - registry1.dsop.io/ironbank/opensource/istio/pilot:1.7.3
    - registry1.dsop.io/ironbank/opensource/istio/proxyv2:1.7.3
    - registry1.dsop.io/ironbank/opensource/jaegertracing/all-in-one:1.19.2
    - registry1.dsop.io/ironbank/opensource/jimmidyson/configmap-reload:v0.4.0
    - registry1.dsop.io/ironbank/opensource/kiali/kiali:v1.23.0
    - registry1.dsop.io/ironbank/opensource/openpolicyagent/gatekeeper:v3.1.2
    - registry1.dsop.io/ironbank/opensource/prometheus/alertmanager:v0.21.0
    - registry1.dsop.io/ironbank/opensource/prometheus/node-exporter:v1.0.1
    - registry1.dsop.io/ironbank/opensource/prometheus/prometheus:v2.22.0
EOF
