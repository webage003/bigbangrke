# Airgapped Bundle
This project will bundle all of the Big Bang artifacts from the latest
release.

**These instructions are:**
* **focused on deploying Big Bang after an appropriate airgapped bundle
has already been created and the prerequisite Kubernetes cluster has been stood up**
* **based off our current bundling process where we include a bare-bones 
git server container image as part of the bundling**
* **structured around assuming that users will use kustomize to apply changes 
to the Big Bang charts to more easily tweak Big Bang configuration options for their environments**

WIPS:
* prereqs  
* fill out details on deploying an EC2 instance
* Alternate instructions for Kubernetes distributions which do not have repo mirroring capabilities


### Airgapped Environment Requirements

- rke2/k3s cluster
    - Kubernetes cluster CPU, Memory, and Disk space vary depending on what is enabled. If everything is enabled, the following is the minimum viable setup: vCores - 8 Memory - 32GB Disk Space - 20GB
- `Flux CLI >= v0.5.2`
- `sops`
- `kustomize`
- `kubectl`
- `docker`: for running docker registry.
- `openssl` for self-signed certificate.
- `curl`: For troubleshooting registry.

## Prep Work, Prerequisites & Assumptions:
* You are able to deploy AMIs as EC2 instances
* You have an AMI configured with the required tools (or an alternative server with them installed)
* Grab a copy of the `udn-template` repository from here: https://gitlab.global.lmco.com/software-factory/platform-one/big-bang/customers/udn-template and bring over the entire repo to your UDN machine.

* Download the Big Bang bundle from: https://p1-airgapped-bundle.s3.amazonaws.com/bb-latest <br/>
Extract the Big Bang bundle to your working area on the standalone instance you created above. You should have a folder structure similar to the following:
```
    bb-bundle.tar.gz
    │   git-server.tar
    └───1.6.0
    │    │   images.tar.gz
    │    │   images.txt
    │    │   repositories.tar.gz
    │
    └───security-scans
         │   aqua-summary.txt
         └───1.6.0
              │  [folders for each image bundled]
              │  ...
```

* Deploy an EC2 instance with the k3s_udn_node AMI in the us-gov-east-1 region.
```
detailed instructions for ec2 deployment
```

### Package Specific Prereqs

#### Elastic (Logging)

Elastic requires a larger number of memory map areas than some OSes support by default. This can be change at startup with a cloud config or later using sysctl.

```
MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
    
    --==MYBOUNDARY==
    Content-Type: text/x-shellscript; charset="us-ascii"

    #!/bin/bash
    # Set the vm.max_map_count to 262144. 
    # Required for Elastic to run correctly without OOM errors.
    sysctl -w vm.max_map_count=262144
```


## General Information:
* If you modify the keys underneath the git server container, you must restart the git-server container for changes to appear. git-server only reads its files on startup.

---
## 1. Initial environment setup
We'll need to perform some general environment setup first: configuring the git server we'll be using for our GitOps and a basic Docker registry to serve the Big Bang images we'll need. We'll use a simple standalone EC2 instance to serve these Docker containers (but any server accessible to your cluster and with the needed tools defined above should work).

>**These two containers are meant to be simple utilities only used for Big Bang deployment. Use beyond these purposes is as-is.**

#### 1.1. Configure your git server and mount repos/keys 
1. Create an ssh keypair with no passphrase. Call it `identity`.
   ```bash
   ec2-user@[standalone-ec2-instance]$ ssh-keygen -t rsa
   ```

2. Create a folder at `~/git-server`
   ```bash
   ec2-user@[standalone-ec2-instance]$ mkdir ~/git-server
   ```

3. Extract repositories.tar.gz contents to `~/git-server/`. You should have a `repos` folder inside now.
   ```bash
   ec2-user@[standalone-ec2-instance]$ tar -zxvf bundle/1.6.0/repositories.tar.gz -C ~/git-server/
   ```

4. Extract and move your `udn-template` copy into `~/git-server/repos`
   ```bash
   ec2-user@[standalone-ec2-instance]$ tar -zxvf bundle/udn-template.tar.gz -C ~/git-server/repos/
   ```

5. Copy your ssh credentials into `~/git-server/keys`
   ```bash
   ec2-user@[standalone-ec2-instance]$ mkdir ~/git-server/keys/
   ec2-user@[standalone-ec2-instance]$ cp ~/.ssh/identity* ~/git-server/keys/
   ```

6. Add the git-server docker container to your local container registry
   ```bash
   ec2-user@[standalone-ec2-instance]$ docker load < git-server.tar
   ```

7. Verify that the git-server docker image loaded correctly
   ```bash
   ec2-user@[standalone-ec2-instance]$ docker images
   ```

8. Copy the git-server docker image name from above. Run the git-server docker container and mount the keys and repos directories into the container
   ```bash
   ec2-user@[standalone-ec2-instance]$ docker run -d -p 2222:22 --restart=always -v ~/git-server/keys:/git-server/keys -v ~/git-server/repos:/git-server/repos [git-server docker image:tag]
   ```

#### 1.2 Pull down Git repositories for later use

It's helpful to have the `bigbang` and `udn-template` repositories cloned on your control plane node, and to use that area as your working area for the following steps. You should have added the `udn-template` repository to your git server earlier. 

1. Copy the identity files to your control plane node.
   ```bash
   ec2-user@[standalone-ec2-instance]$ scp -i [AWS identity key file] ~/.ssh/identity* [control-plane-ip]:~/.ssh/
   ```

2. Then set up an ssh `config` file on the control plane node:
   ```bash
   ec2-user@[control-plane-node]$ touch ~/.ssh/config
   ec2-user@[control-plane-node]$ chmod 600 ~/.ssh/config
   ```

   And the contents of the `config` file should be:

   ```ssh
   Host [standalone ec2 instance IP]
     HostName [standalone ec2 instance IP]
     IdentityFile ~/.ssh/identity
   ```

3. With your ssh keys configured, clone those repos with the following commands:

   ```bash
   ec2-user@[control-plane-node]$ git clone ssh://git@[git-server-ip]:2222/git-server/repos/bigbang/.git
   ec2-user@[control-plane-node]$ git clone ssh://git@[git-server-ip]:2222/git-server/repos/udn-template/.git
   ```

   We also need the SSH fingerprint of the git-server later as part of creating secrets, so this serves a dual purpose.

#### 1.3. Configure your container registry

1. Extract the images.tar.gz file
   ```bash
   ec2-user@[standalone-ec2-instance]$ tar -zxvf bundle/1.6.0/images.tar.gz -C ~/
   ```

2. Load registry image into your local Docker (if you cannot access this directory, chmod +x the 1.6.0/var/lib/registry directory)
   ```bash
   ec2-user@[standalone-ec2-instance]$ docker load < var/lib/registry/registry.tar
   ```

3. Create the SSL certificates we need for the Docker registry and start the registry container.
   ```bash
   ec2-user@[standalone-ec2-instance]$ sudo ~/udn-template/scripts/start-registry.sh
   ```
   The script will prompt you for several values. The defaults it suggests are mostly fine. You can customize the State and Location, following the pattern set by the prompt, for your specific scenario. For the Organization, put `ADP` and for the Common Name, put a throwaway but unique Fully Qualified Domain Name such as `bigbang.[project_name].udn.adp`. If you want to use the FQDN long-term instead of the registry instance's IP address for other things, this guide does not cover those steps.<br/>

   For the Subject Alternative Names, enter `IP:[standalone-ec2-instance-ip]`



4. Verify functionality. You should see a listing of Big Bang and other container images.
   ```bash
   ec2-user@[standalone-ec2-instance]$ curl https://127.0.0.1:5000/v2/_catalog -k
   ```

---
## 2. Configure your cluster before big bang deployment
There are a few more steps to configure the cluster for our Big Bang deployment.

_These instructions are written assuming you use the control plane node as your working environment._

#### 2.1. Update cluster nodes to trust container registry and add repo mirroring
>**This section currently assumes you're using k3s or another k3s-based distribution.**

1. Create a `registries.yaml` file as below. You will need to insert the IP address of your Docker registry container's host (the standalone EC2 instance). <br/>
Additionally, this uses the public .pem file generated by the certs step you created above as part of standing up the Docker registry container.
   ```yaml
   mirrors:
     registry.dso.mil:
       endpoint:
         - https://[docker-registry-host-ip]:5000
     registry1.dso.mil:
       endpoint:
         - https://[docker-registry-host-ip]:5000
     docker.io:
       endpoint:
         - https://[docker-registry-host-ip]:5000
   configs:
     [docker-registry-host-ip]:5000:
       tls:
         ca_file: "/etc/ssl/certs/[cert-name].crt"
   ```

2. Place registries.yaml at /etc/rancher/k3s/ on every node in the cluster (workers and control plane(s))
3. Place the `.crt` file from the previous registry x509 certificate generation step on each node matching location defined in `registries.yaml`
4. Restart k3s processes (`systemctl restart k3s` on control plane, `systemctl restart k3s-agent` on workers)

#### 2.2. Create ssh-credentials secret in k3s cluster in bigbang and flux-system namespace
1. Run the following commands:
   ```bash
   ec2-user@[control-plane-node]$ cd ~/.ssh/
   ec2-user@[control-plane-node]$ sudo kubectl create ns bigbang
   ec2-user@[control-plane-node]$ sudo kubectl create ns flux-system
   ec2-user@[control-plane-node]$ sudo kubectl create secret generic ssh-credentials -n bigbang --from-file=./identity --from-file=./identity.pub --from-file=./known_hosts
   ec2-user@[control-plane-node]$ sudo kubectl create secret generic ssh-credentials -n flux-system --from-file=./identity --from-file=./identity.pub --from-file=./known_hosts
   ```

#### 2.3. Deploy flux to the cluster
1. copy `bigbang/scripts/deploy/flux.yaml` to `udn-template/flux/`
   ```bash
   ec2-user@[control-plane-node]$ cp bigbang/scripts/deploy/flux.yaml udn-template/flux/
   ```

2. Update our copy of `flux.yaml` to add the following code snippets to kustomize-controller deployment pod spec.
    * In the `volumeMounts` section, we want to add the following code:
    ```yaml
          volumeMounts:
            ...
            - mountPath: /home/controller
              name: ssh
            - mountPath: /keys
              name: ssh-credentials
          lifecycle:
            postStart:
                exec:
                  command:
                    - sh
                    - "-c"
                    - mkdir -p ~/.ssh && cat /keys/identity > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa && cat /keys/identity.pub > ~/.ssh/id_rsa.pub && cat /keys/known_hosts > ~/.ssh/known_hosts
    ```
    * In the `volumes` section, we want to add the following: 
    ```yaml
      - emptyDir: {}
        name: ssh
      - name: ssh-credentials
        secret:
          secretName: ssh-credentials
          defaultMode: 0755
    ```
> The emptyDir above does matter. Without it, the flux pods don't seem to recognize that ssh credentials exist.

The overall modified kustomize-controller deployment should similar to this:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/instance: flux-system
    app.kubernetes.io/version: v0.10.0
    control-plane: controller
  name: kustomize-controller
  namespace: flux-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kustomize-controller
  template:
    metadata:
      annotations:
        prometheus.io/port: "8080"
        prometheus.io/scrape: "true"
      labels:
        app: kustomize-controller
    spec:
      containers:
      - args:
        - --events-addr=http://notification-controller/
        - --watch-all-namespaces=true
        - --log-level=info
        - --log-encoding=json
        - --enable-leader-election
        env:
        - name: RUNTIME_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        image: registry1.dso.mil/ironbank/fluxcd/kustomize-controller:v0.9.3
        imagePullPolicy: IfNotPresent
        livenessProbe:
          httpGet:
            path: /healthz
            port: healthz
        name: manager
        ports:
        - containerPort: 9440
          name: healthz
          protocol: TCP
        - containerPort: 8080
          name: http-prom
        readinessProbe:
          httpGet:
            path: /readyz
            port: healthz
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 1000m
            memory: 1Gi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
        volumeMounts:
        - mountPath: /tmp
          name: temp
        - mountPath: /home/controller
          name: ssh
        - mountPath: /keys
          name: ssh-credentials
        lifecycle:
          postStart:
            exec:
              command:
                - sh
                - "-c"
                - mkdir -p ~/.ssh && cat /keys/identity > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa && cat /keys/identity.pub > ~/.ssh/id_rsa.pub && cat /keys/known_hosts > ~/.ssh/known_hosts
      imagePullSecrets:
      - name: private-registry
      nodeSelector:
        kubernetes.io/os: linux
      securityContext:
        fsGroup: 1337
      serviceAccountName: kustomize-controller
      terminationGracePeriodSeconds: 60
      volumes:
      - emptyDir: {}
        name: temp
      - emptyDir: {}
        name: ssh
      - name: ssh-credentials
        secret:
          secretName: ssh-credentials
          defaultMode: 0755
```


3. run kustomize on our newly modified `flux.yaml`
   ```bash
   ec2-user@[control-plane-node]$ cd udn-template/flux
   ec2-user@[control-plane-node]$ kustomize build . | sudo kubectl apply -f -
   ```

4. You should see the flux deployment happen in the `flux-system` namespace.
   ```bash
   ec2-user@[control-plane-node]$ watch sudo kubectl get all -n flux-system
   ```

#### 2.4. Create the SOPS secret Big Bang needs
1. Run `bigbang/hack/sops-create.sh` from anywhere on the control plane node to create a SOPS secret for the cluster (needed by bigbang helm deploys later)

---

## 3. Deploy Big Bang

1. Update `udn-template/base/kustomization.yaml` to point at our local git server
   ```yaml
   bases:
   - "git::ssh:://git@[git-server-ip]:2222/git-server/repos/bigbang/.git//base?ref=1.6.0"
   ```

2. Update `udn-template/base/lm-values.yaml` to point all git repo URLs at our local git server.
   Also comment out all of the container image URLs; leaving the deployments to use the defaults will result in the repo mirroring we set up handling all the redirects we need.
   > If your Kubernetes distribution does not have repo mirroring, you must update these container image URLs to point at our local Docker registry
   ```yaml
   istio:
     git:
       repo: ssh://git@[git-server-ip]:2222/git-server/repos/istio-controlplane/.git
     values:
       #hub: registry.us.lmco.com/istio
       #proxy:
         #image: registry.us.lmco.com/dcar-opensource/istio-1.7-proxyv2-1.7:1.7.7
   ...
   ```

3. Update `set-lm-git-repo.yaml` to point at local network git repo host and add the ssh-credentials secretRef
   ```yaml
   ---
   apiVersion: source.toolkit.fluxcd.io/v1beta1
   kind: GitRepository
   metadata:
     name: bigbang
   spec:
     ref:
       $patch: replace
       semver: "1.6.0" #[replace with the current version of Big Bang being deployed]
     url: "ssh://git@[git-server-ip]:2222/git-server/repos/bigbang/.git
     secretRef:
       name: "ssh-credentials"
   ```

4. Update `udn-template/dev/bigbang.yaml` [THIS STEP TO BE MODIFIED WHEN WE HAVE A UDN OR AIRGAPPED TEMPLATE IN THE REPO]
   ```yaml
   apiVersion: v1
   kind: Namespace
   metadata:
     name: bigbang
   ---
   apiVersion: source.toolkit.fluxcd.io/v1beta1
   kind: GitRepository
   metadata:
     name: environment-repo
     namespace: bigbang
   spec:
     interval: 1m
     url: ssh://git@[git-server-ip]:2222/git-server/repos/udn-template/.git
     ref:
       branch: udn-kustomization #use whatever branch you wind up putting your kustomizations in if they're not in the main branch
     secretRef:
       name: "ssh-credentials"
   ---
   apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
   kind: Kustomization
   metadata:
     name: environment
     namespace: bigbang
   spec:
     interval: 1m
     sourceRef:
       kind: GitRepository
       name: environment-repo
     path: ./dev
     prune: true
     decryption:
       provider: sops
       secretRef:
         name: sops-gpg
   ```

5. Update `udn-template/dev/configmap.yaml` by appending to the bottom of the file the following:
   ```yaml
   git:
     existingSecret: "ssh-credentials"
   ```

6. Commit your changes to your local copy of `udn-template`. After the objects are created, Flux will pull configuration and other data it needs from the git repositories, rather than using your local copies.

7. Deploy `udn-template` kustomizations to the cluster
    ```bash
    ec2-user@[control-plane-node]$ cd udn-template/dev
    ec2-user@[control-plane-node]$ sudo kubectl apply -f bigbang.yaml
    ```

8. Wait for the deployments to reconcile and finish (could take up to 10 minutes)
   ```bash
   ec2-user@[control-plane-node]$ sudo kubectl get gitrepositories,hr,ks,pods -A
   ```
