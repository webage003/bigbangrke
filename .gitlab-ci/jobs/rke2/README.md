# Overview

This job spins up a rke2 cluster inside of a precreated VPC. 

## Gitlab-ci

We run a terraform apply from the `.gitlab-ci/jobs/rke2/dependencies/terraform/env/ci` dir.

Once the cluster is created we create a default storage class in the cluster using `.gitlab-ci/jobs/rke2/dependencies/k8s-resources/aws/default-ebs-sc.yaml`

The kubeconfig file is also stored as an artifact:

```yaml
  artifacts:
    paths:
      - ${CI_PROJECT_DIR}/rke2.yaml
```

## Local Dev

### Prereqs

* The networking job must have been locally run and a VPC must exist:

```bash
cd .gitlab-ci/jobs/networking/aws/dependencies/terraform/env/dev
tf init
tf plan
tf apply
```

### Steps

* Run the tf to instantiate the rke2 cluster:

```bash
cd .gitlab-ci/jobs/rke2/dependencies/terraform/env/dev
tf init
tf plan
tf apply
```
