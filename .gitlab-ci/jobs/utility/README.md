# Overview

This job creates a utility instance in the previously created private subnet which contains three processes: a forward, internet facing proxy, git repository, and docker registry. The git repository is preloaded with the umbrella application repository and the docker registry contains images from iron bank. Additionally, Route 53 internal records are created which will resolve to these services.

Note that pulling from the git repository is done over http://repository.dsop.io/umbrella.git

Note that this step consumes a tf state from the previous networking job. This is done through a remote state hosted in S3 or local file if in Dev. 

Note that this job also publishes a state containing a registry username and password so that you only need to define it once. If left blank, both the username and password will be randomly generated.

## Gitlab-ci

We run a terraform apply from the `.gitlab-ci/jobs/utility/dependencies/terraform/env/ci` dir.

Output is the ip of the utility instance. This does not need to be consumed given that pre-defined Route 53 records are created:

* proxy.dsop.io
* repository.dsop.io
* registry.dsop.io

repository.dsop.io and registry.dsop.io are blank and require artifacts to be pushed into them. This is done with `git push` and `docker push` respectively. Both of these resources are secured behind basic auth which may be randomly generated during `terraform apply`. To consume this auth, use the following terraform state method to retrieve the credentials.

main.tf
```
variable "env" {}

data "terraform_remote_state" "utility" {
  backend = "s3"
  config = {
    bucket               = "umbrella-tf-states"
    key                  = "terraform.tfstate"
    region               = "us-gov-west-1"
    workspace_key_prefix = "utility"
  }
  workspace = var.env
}

output "utility_username" {
    value = data.terraform_remote_state.utility.utility_username
}

output "utility_password" {
    value = data.terraform_remote_state.utility.utility_password
}
```

get_auth.sh
```bash
#/bin/bash
terraform init
terraform plan
terraform apply --auto-approve
export utility_username=`terraform output utility_username`
export utility_password=`terraform output utility_password`
```

## Local Dev

### Prereqs

* The networking job must have been run:

### Steps

* Run the tf to instantiate the EC2 Instance:

```bash
cd .gitlab-ci/jobs/utility/dependencies/terraform/env/dev
tf init
tf plan
tf apply --auto-approve
```

* Cannonical next step is [rke2](../../rke2/README.md)

* Once finished:

```bash
cd .gitlab-ci/jobs/utility/dependencies/terraform/env/dev
tf destroy --auto-approve
```