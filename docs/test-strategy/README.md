## Testing the Bigbang release. 

Before any Bigbang release is cut , the following steps listed below cover current tests that are run. 




**Confirm app UIs are loading**

-  anchore
- argocd
- gitlab
-  tracing
-   kiali
-  kibana
-  mattermost
-  minio
- alertmanager
-  grafana
-  prometheus
- sonarqube
-  twistlock
-  nexus
-  TLS/SSL certs are valid

**Logging**

-  Login to kibana with SSO
-  Kibana is actively indexing/logging.

**Cluster Auditor**

-  Login to kibana with SSO
-  violations index is present and contains images that aren't from registry1

**Monitoring**

-  Login to grafana  with SSO
-  Contains Kubernetes Dashboards and metrics
-  contains istio dashboards
-  Login to prometheus
-  All apps are being scraped, no errors

**Kiali**

-  Login to kiali with SSO

**Sonarqube**

-  Login to sonarqube with SSO

**GitLab & Runners**

-  Login to gitlab with SSO
-  Create new public group with release name. Example `release-1-8-0`
-  Create new public project with release name.  Example `release-1-8-0`
-  git clone and git push to new project
-  docker push and docker pull image to registry

    ```
    docker pull alpine
    docker tag alpine registry.dogfood.bigbang.dev/GROUPNAMEHERE/PROJECTNAMEHERE/alpine:latest
    docker login registry.dogfood.bigbang.dev
    docker push registry.dogfood.bigbang.dev/GROUPNAMEHERE/PROJECTNAMEHERE/alpine:latest
    ```

-  Edit profile and change user avatar
-  Test simple CI pipeline.  `sample_ci.yaml` using the example content below.
     <details>
    <summary>Example</summary>

    ```yaml
    stages:
    - test
    dogfood:
        stage: test
        script:
          - echo "dogfood" >> file.txt
        artifacts:
            paths:
              - file.txt
    cache:
        paths:
          - file.txt
   ```
    </details>

**Anchore**

-  Login to anchore with SSO
-  Scan image in dogfood registry, i.e `registry.dogfood.bigbang.dev/GROUPNAMEHERE/PROJECTNAMEHERE/alpine:latest`

**Argocd**

-  Login to  argocd with SSO
-  Logout and login with `admin`. [password reset](https://argoproj.github.io/argo-cd/faq/#i-forgot-the-admin-password-how-do-i-reset-it)
-  Create application
    ```
    *click* create application
    application name: argocd-test
    Project: default
    Sync Policy: Automatic
    Sync Policy: check both boxes
    Sync Options: check both boxes
    Repository URL: https://github.com/argoproj/argocd-example-apps
    Revision: HEAD
    Path: helm-guestbook
    Cluster URL: https://kubernetes.default.svc
    Namespace: argocd-test
    *click* Create (top of page)
    ```
-  Delete application

**Minio**

-  Create bucket
-  Store file to bucket
-  Download file from bucket
-  Delete bucket and files

**Mattermost**

-  Login to mattermost with SSO
-  Elastic integration

**Velero**

-  Backup PVCs
    * create a manifest file `velero_test.yaml` with the content below. 
<details>
<summary>Example</summary>


```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: velero-test
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: velero-test
  namespace: velero-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: velero-test
  namespace: velero-test
  labels:
    app: velero-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: velero-test
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: velero-test
    spec:
      containers:
        - image: ubuntu:xenial
          imagePullPolicy: Always
          command: ["/bin/sh", "-c"]
          args:
            - sleep 30; touch /mnt/velero-test/test.log; while true; do date >> /mnt/velero-test/test.log; sleep 10; done;
          name: velero-test
          stdin: true
          tty: true
          livenessProbe:
            exec:
              command:
                - timeout
                - "10"
                - ls
                - /mnt/velero-test
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 10
          volumeMounts:
            - mountPath: /mnt/velero-test
              name: velero-test
      restartPolicy: Always
      volumes:
        - name: velero-test
          persistentVolumeClaim:
            claimName: velero-test
```
</details>

Then run the following commands 

    ```
    kubectl apply -f ./velero_test.yaml
    # exec into velero_test container
    cat /mnt/velero-test/test.log
    # take note of log entries and exit exec 
    ```

    ```
    velero backup create velero-test-backup-1-8-0 -l app=velero-test
    velero backup get
    kubectl delete -f ./velero_test.yaml
    kubectl get pv | grep velero-test
    kubectl delete pv INSERT-PV-ID
    ```

-  Restore PVCs

    ```
    velero restore create velero-test-restore-1-8-0 --from-backup velero-test-backup-1-8-0
    # exec into velero_test container
    cat /mnt/velero-test/test.log
    # old log entires and new should be in log if backup was done correctly
    ```