# Overview

This job spins up a VPC, and private,public and intra subnets inside an AWS account (and other things like IGW etc). The purpose of this job is to deploy this base networking infra so that other jobs in the umbrella pipeline may consume the tf-outputs and deploy further resources inside the VPC and subnets that are created. 

## Gitlab-ci

We run a quick python script `get-vpc.py` to calculate the unique cidr range for the VPC.
We then run a terraform apply from the `.gitlab-ci/jobs/networking/aws/dependencies/terraform/env/ci` dir.

Other jobs can consume the `tf-outputs` via `data "terraform_remote_state"`.

## Local Dev

### Prereqs

* Terraform installed
* AWS cli installed
* AWS profile and credentials set up

### Steps

* Run the tf to instantiate the vpc and other networking:

```bash
cd .gitlab-ci/jobs/networking/aws/dependencies/terraform/env/dev
tf init
tf plan
tf apply
```
