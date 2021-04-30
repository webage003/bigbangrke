# EdgeONE Provider CaC

This document is referencing the code located in the following repo:

[https://code.il2.dso.mil/platform-one/products/edge-one/edge-provider](https://code.il2.dso.mil/platform-one/products/edge-one/edge-provider)

## Overview

This EdgeONE Provider repostory provides Configuration as Code(CaC) to replicate ABMS software artifacts to a Provider environment.

The Provider is capable of replicating itself to remote systems to initialize, mirror, and incrementally update an ABMS Platform One deployment, leveraging DevSecOps practices.

The Provider services include:

- Docker registry, mirroring container images from Iron Bank and other sources
- RPM server to mirror CentOS RPM packages
- A helm chart repository(Chart Museum), and mirroring of charts
- Git repository cloning and lifecycle

## Prerequisites

Hardware Prerequisites:

- 4 hosts, VM or otherwise.  Each sharing the same user credentials
- 32gb RAM, 128gb free space
- centOS 8

Software Prerequesites:

- python/pip, otherwise everything else is installed by the install script.


## Cluster Topology

* **Cluster Control Plane Nodes** – HA k8s nodes to run the cluster
* **Cluster Agent Nodes** – k8s agents to delegate work to
* **Cluster Provider** – A server which provides all the necessary artifacts for the cluster to operate:
    1. git repos
    1. docker images
    1. helm charts
    1. RPM packages

This is bootstrapped by another machine which we call the **Workstation Provider**.
This machine is connected to the internet at one point in time in order to fetch all the artifacts needed for the entire cluster to run airgapped.

## An Example Cluster Bootstrap Timeline

#### internet connected

1. The Workstation Provider fetches all artifacts needed for the Cluster Provider host and the scripts needed to bootstrap the Agent and Control Plane nodes.

#### air gapped (workstation provider present)

1. The Workstation Provider is transferred on-site onto a network with the cluster provider and hosts.
1. A script is run on the Workstation Provider set up the cluster provider:
    1. rsync artifacts
    1. ssh in and configure servers for docker images, rpms, charts, and git repositories
    1. Another script is run to kick off the k8s nodes
    1. rsync artifacts needed for a functional cluster
    1. ssh in and run scripts needed to start the control plane nodes and/or join agent nodes to the cluster
    1. configure the cluster to reference the cluster provider for any artifacts needed to operate

#### air gapped (workstation provider absent)

The cluster is running airgapped solely relying on the cluster provider host


## Requirements and Prerequisites

The commands and ansible playbooks contained within this repository currently require a CentOS 8 environment.

A `minimal` release is recommended for reduced file size.

The recommended release is `CentOS-8.2.2004-x86_64-minimal`

**_Start a SSH Session to the "Provider" VM_**

## Using This repository

### Generate a PAT(Personal Access Token)

1. Log in to [Code IL2](https://code.il2.dso.mil) GitLab from a browser in your workstation
1. Navigate to the [Personal Access Tokens](https://code.il2.dso.mil/profile/personal_access_tokens)
1. Name the token `EDGE-PROVIDER-[TODAYS DATE]`(ex: `EDGE-PROVIDER-2021-01-20`)
1. Select a date no more than fourteen(14) days from the current date for expiration
1. Under Scopes, select **_only_** `api`, `read_repository`, `read_registry`
1. Click the `Create personal access token` button
1. Copy the newly generated PAT to an appropriate secret manager

**_DO NOT SHARE YOUR PAT WITH OTHER USERS_**

### Clone the Repository

From the command line of your provider environment, run the following command:

Type `git clone https://code.il2.dso.mil/platform-one/products/edge-one/edge-provider.git --depth 1 --branch master --single-branch`

- Username: Your platform one username.
- Password: Use the PAT generated above.

    Type `cd edge-provider`

    **_If your PAT has expired for further git operations, follow the Generate PAT steps again and enter when prompted._**

## Initialize the Repository

Type `` `which sh` ./bin/init.sh``

## Updating the Repository

To retrieve updates to the repository from GitLab:

Type `git pull`

Then run the [initialize command](#Initialize-the-Repository).

## `user.ini` Configuration

Supported Playbooks:
- `provider-pull`

    1. Log into https://registry1.dso.mil/ from a browser
    1. Click your username in top right, then "User Profile"
    1. Copy the "Username" to use in a later step
    1. Copy the "CLI secret" to use in a later step
    1. Back in the Server SSH type `nano user.ini`
    1. Add your username and secret in the registry1 variables at the bottom of user.ini
    1. Add your username and secret in the codeil2 variables at the bottom of user.ini(Use the PAT generated for Code IL2 above)
    1. Press `CTRL + X` to save the .ini file
    1. Press `y` to save the changes to the .ini file Press `enter` to overwrite the user.ini file
    1. Type `cat user.ini` to verify the changes

## `deployment.ini` Configuration

To create a deployment, type:

`sh ./bin/create-deployment <deployment-name>`

### Cluster Provider Configuration

Supported Playbooks:
- `provider-push`

    1. Type `nano ./local/<deployment-name>/inventory/deployment.ini`
    1. Put the IP address of the cluster provider on the line below `[cluster-provider]`

### Cluster Configuration

Supported Playbooks:
- `k8s-install`
- `uninstall-all`

    1. Type `nano ./local/<deployment-name>/inventory/deployment.ini`
    1. Enter the IP addresses of the control plane nodes under `[k8s-control-plane-nodes]`
    1. If applicable, enter the IP addresses of the worker nodes under `[k8s-worker-nodes]`
    - Use the IP address of the first control plane node as the join_to value for all worker nodes

## Running Playbooks:

To run a playbook, type:

`sh ./bin/play <playbook-name> <deployment-name>`

## Playbooks

### `provider-pull`

Requirements: Complete the `user.ini` Configuration

An internet connection to the Platform One(dso.mil) services and other public resources such as Docker Hub is required for this playbook. You must also have recently logged in to [Registry1](https://registry1.dso.mil/)

This playbook will clone all artifacts necessary for an air gapped installation to the machine running it. A local/workstation provider should be considered ephemeral, and used only for transport of artifacts to be "pushed" to a remote provider.

To run, type:
`sh ./bin/play.sh provider-pull <deployment-name>`

### `provider-push`

Requirements: Complete Cluster Provider Configuration for your deployment

Description: Install and run `edge-provider` services on a server, mirroring artifacts for air gapped deployments.

To run, type:
`sh ./bin/play.sh provider-push <deployment-name>`

### `k8s-install`

Requirements: Complete Cluster Configuration for your deployment

Description: Deploy a kubernetes cluster and Big Bang to the targeted servers

To run, type:
`sh ./bin/play.sh k8s-install <deployment-name>`


