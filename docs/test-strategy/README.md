## Testing the Bigbang release. 

Before any Bigbang release is cut , the following steps listed below cover current tests that are run. 




**Confirm app UIs are loading**

- [x] anchore
- [x] argocd
- [x] gitlab
- [x] tracing
- [x] kiali
- [x] kibana
- [x] mattermost
- [x] minio
- [x] alertmanager
- [x] grafana
- [x] prometheus
- [x] sonarqube
- [x] twistlock
- [x] nexus
- [x] TLS/SSL certs are valid

**Logging**

- [x] Login to kibana with SSO
- [x] Kibana is actively indexing/logging.

**Cluster Auditor**

- [x] Login to kibana with SSO
- [x] violations index is present and contains images that aren't from registry1

**Monitoring**

- [x] Login to grafana  with SSO
- [x] Contains Kubernetes Dashboards and metrics
- [x] contains istio dashboards
- [x] Login to prometheus
- [x] All apps are being scraped, no errors

**Kiali**

- [x] Login to kiali with SSO

**Sonarqube**

- [x] Login to sonarqube with SSO

**GitLab & Runners**

- [x] Login to gitlab with SSO
- [x] Create new public group with release name. Example `release-1-8-0`
- [x] Create new public project with release name.  Example `release-1-8-0`
- [x] git clone and git push to new project
- [x] docker push and docker pull image to registry

    ```
    docker pull alpine
    docker tag alpine registry.dogfood.bigbang.dev/GROUPNAMEHERE/PROJECTNAMEHERE/alpine:latest
    docker login registry.dogfood.bigbang.dev
    docker push registry.dogfood.bigbang.dev/GROUPNAMEHERE/PROJECTNAMEHERE/alpine:latest
    ```

- [x] Edit profile and change user avatar
- [x] Test simple CI pipeline. [sample_ci.yaml](https://repo1.dso.mil/platform-one/big-bang/customers/bigbang/-/raw/master/docs/release/sample_ci.yaml)

**Anchore**

- [x] Login to [anchore](https://anchore.dogfood.bigbang.dev) with SSO
- [x] Scan image in dogfood registry, `registry.dogfood.bigbang.dev/GROUPNAMEHERE/PROJECTNAMEHERE/alpine:latest`

**Argocd**

- [x] Login to  argocd with SSO
- [x] Logout and login with `admin`. [password reset](https://argoproj.github.io/argo-cd/faq/#i-forgot-the-admin-password-how-do-i-reset-it)
- [x] Create application
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
- [x] Delete application

**Minio**

- [x] Create bucket
- [x] Store file to bucket
- [x] Download file from bucket
- [x] Delete bucket and files

**Mattermost**

- [x] Login to mattermost with SSO
- [x] Elastic integration

**Velero**

- [x] Backup PVCs
    [velero_test.yaml](https://repo1.dso.mil/platform-one/big-bang/customers/bigbang/-/raw/master/docs/release/velero_test.yaml)
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

- [x] Restore PVCs

    ```
    velero restore create velero-test-restore-1-8-0 --from-backup velero-test-backup-1-8-0
    # exec into velero_test container
    cat /mnt/velero-test/test.log
    # old log entires and new should be in log if backup was done correctly
    ```