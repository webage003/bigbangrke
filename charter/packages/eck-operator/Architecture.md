# ECK Operator

## Overview

Elastic Cloud on Kubernetes (ECK) Operator chart.

Originally sourced from [upstream](https://github.com/elastic/cloud-on-k8s/tree/master/deploy/eck-operator), and minimally modified.

## Contents

[Developer Guide](docs/developer-guide.md)

## Big Bang Touchpoints

### Storage
N/A

### Database
N/A

### Istio Configuration
N/A

## High Availability

This can be accomplished by increasing the number of replicas in the deployment.

```yaml
eckoperator:
   values:
      replicaCount: 2
```

## Single Sign on (SSO)
N/A

## Licensing
[ECK License Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-licensing.html#k8s-licensing)
[Start Trial for ECK](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-licensing.html#k8s-start-trial)
[Add a License for ECK](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-licensing.html#k8s-start-trial)
[Update License for ECK](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-licensing.html#k8s-update-license)






