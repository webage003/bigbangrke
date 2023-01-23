# bigbang

![Version: 1.51.0](https://img.shields.io/badge/Version-1.51.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Big Bang is a declarative, continuous delivery tool for core DoD hardened and approved packages into a Kubernetes cluster.

## Upstream References
* <https://p1.dso.mil/#/products/big-bang>

* <https://repo1.dso.mil/platform-one/big-bang/bigbang>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install bigbang chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| domain | string | `"bigbang.dev"` | Domain used for BigBang created exposed services, can be overridden by individual packages. |
| offline | experimental | `false` | Toggle sourcing from external repos. All this does right now is toggle GitRepositories, it is _not_ fully functional |
| registryCredentials | object | `{"email":"","password":"","registry":"registry1.dso.mil","username":""}` | Single set of registry credentials used to pull all images deployed by BigBang. |
| openshift | bool | `false` | Multiple sets of registry credentials used to pull all images deployed by BigBang. Credentials will only be created when a valid combination exists, registry, username, and password (email is optional) Or a list of registires:  - registry: registry1.dso.mil    username: ""    password: ""    email: ""  - registry: registry.dso.mil    username: ""    password: ""    email: "" Openshift Container Platform Feature Toggle |
| git | object | `{"credentials":{"caFile":"","knownHosts":"","password":"","privateKey":"","publicKey":"","username":""},"existingSecret":""}` | Git credential settings for accessing private repositories Order of precedence is:   1. existingSecret   2. http credentials (username/password/caFile)   3. ssh credentials (privateKey/publicKey/knownHosts) |
| git.existingSecret | string | `""` | Existing secret to use for git credentials, must be in the appropriate format: https://toolkit.fluxcd.io/components/source/gitrepositories/#https-authentication |
| git.credentials | object | `{"caFile":"","knownHosts":"","password":"","privateKey":"","publicKey":"","username":""}` | Chart created secrets with user defined values |
| git.credentials.username | string | `""` | HTTP git credentials, both username and password must be provided |
| git.credentials.caFile | string | `""` | HTTPS certificate authority file.  Required for any repo with a self signed certificate |
| git.credentials.privateKey | string | `""` | SSH git credentials, privateKey, publicKey, and knownHosts must be provided |
| sso | object | `{"auth_url":"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}/protocol/openid-connect/auth","certificate_authority":"","client_id":"","client_secret":"","jwks":"","jwks_uri":"","oidc":{"host":"login.dso.mil","realm":"baby-yoda"},"secretName":"tls-ca-sso","token_url":"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}/protocol/openid-connect/token"}` | Global SSO values used for BigBang deployments when sso is enabled, can be overridden by individual packages. |
| sso.oidc.host | string | `"login.dso.mil"` | Domain for keycloak used for configuring SSO |
| sso.oidc.realm | string | `"baby-yoda"` | Keycloak realm containing clients |
| sso.certificate_authority | string | `""` | Keycloak's certificate authority (PEM Format). Entered using chomp modifier (see docs/assets/configs/example/dev-sso-values.yaml for example). Used by authservice to support SSO for various packages |
| sso.jwks | string | `""` | Keycloak realm's json web key output, obtained at https://<keycloak-server>/auth/realms/<realm>/protocol/openid-connect/certs |
| sso.jwks_uri | string | `""` | Optional use of JWKS fetcher config for ease of use and automation. Fill in JWKS URI value of OIDC endpoint, can be found under the well known OpenID metadata configuration page of your provider. |
| sso.client_id | string | `""` | OIDC client ID used for packages authenticated through authservice |
| sso.client_secret | string | `""` | OIDC client secret used for packages authenticated through authservice |
| sso.token_url | string | `"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}/protocol/openid-connect/token"` | OIDC token URL template string (to be used as default) |
| sso.auth_url | string | `"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}/protocol/openid-connect/auth"` | OIDC auth URL template string (to be used as default) |
| sso.secretName | string | `"tls-ca-sso"` | Kubernetes Secret containing the sso.certificate_authority value for SSO enabled application namespaces |
| flux | Advanced | `{"install":{"remediation":{"retries":-1}},"interval":"2m","rollback":{"cleanupOnFail":true,"timeout":"10m"},"test":{"enable":false},"timeout":"10m","upgrade":{"cleanupOnFail":true,"remediation":{"remediateLastFailure":true,"retries":3}}}` | Flux reconciliation parameters. The default values provided will be sufficient for the majority of workloads. |
| networkPolicies | object | `{"controlPlaneCidr":"0.0.0.0/0","enabled":true,"nodeCidr":"","vpcCidr":"0.0.0.0/0"}` | Global NetworkPolicies settings |
| networkPolicies.enabled | bool | `true` | Toggle all package NetworkPolicies, can disable specific packages with `package.values.networkPolicies.enabled` |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` | Control Plane CIDR, defaults to 0.0.0.0/0, use `kubectl get endpoints -n default kubernetes` to get the CIDR range needed for your cluster Must be an IP CIDR range (x.x.x.x/x - ideally with /32 for the specific IP of a single endpoint, broader range for multiple masters/endpoints) Used by package NetworkPolicies to allow Kube API access |
| networkPolicies.nodeCidr | string | `""` | Node CIDR, defaults to allowing "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "100.64.0.0/10" networks. use `kubectl get nodes -owide` and review the `INTERNAL-IP` column to derive CIDR range. Must be an IP CIDR range (x.x.x.x/x - ideally a /16 or /24 to include multiple IPs) |
| networkPolicies.vpcCidr | string | `"0.0.0.0/0"` | VPC CIDR, defaults to 0.0.0.0/0 In a production environment, it is recommended to setup a Private Endpoint for your AWS services like KMS or S3. Please review https://docs.aws.amazon.com/kms/latest/developerguide/kms-vpc-endpoint.html to setup routing to AWS services that never leave the AWS network. Once created update `networkPolicies.vpcCidr` to match the CIDR of your VPC so Vault will be able to reach your VPCs DNS and new KMS endpoint. |
| imagePullPolicy | string | `"IfNotPresent"` | Global ImagePullPolicy value for all packages Permitted values are: None, Always, IfNotPresent |
| istio | object | `{"enabled":true,"enterprise":false,"flux":{},"gateways":{"public":{"autoHttpRedirect":{"enabled":true},"hosts":["*.{{ .Values.domain }}"],"ingressGateway":"public-ingressgateway","tls":{"cert":"","key":""}}},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/istio-controlplane.git","tag":"1.16.1-bb.0"},"ingressGateways":{"public-ingressgateway":{"kubernetesResourceSpec":{},"type":"LoadBalancer"}},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Istio  |
| istio.enabled | bool | `true` | Toggle deployment of Istio. |
| istio.enterprise | bool | `false` | Tetrate Istio Distribution - Tetrate provides FIPs verified Istio and Envoy software and support, validated through the FIPs Boring Crypto module. Find out more from Tetrate - https://www.tetrate.io/tetrate-istio-subscription |
| istio.gateways.public.autoHttpRedirect | object | `{"enabled":true}` | Controls default HTTP/8080 server entry with HTTP to HTTPS Redirect. |
| istio.flux | object | `{}` | Flux reconciliation overrides specifically for the Istio Package |
| istio.values | object | `{}` | Values to passthrough to the istio-controlplane chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/istio-controlplane.git |
| istio.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| istiooperator.enabled | bool | `true` | Toggle deployment of Istio Operator. |
| istiooperator.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/core/istio-operator.git"` |  |
| istiooperator.git.path | string | `"./chart"` |  |
| istiooperator.git.tag | string | `"1.16.1-bb.0"` |  |
| istiooperator.flux | object | `{}` | Flux reconciliation overrides specifically for the Istio Operator Package |
| istiooperator.values | object | `{}` | Values to passthrough to the istio-operator chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/istio-operator.git |
| istiooperator.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| jaeger.enabled | bool | `true` | Toggle deployment of Jaeger. |
| jaeger.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/core/jaeger.git"` |  |
| jaeger.git.path | string | `"./chart"` |  |
| jaeger.git.tag | string | `"2.38.0-bb.1"` |  |
| jaeger.flux | object | `{"install":{"crds":"CreateReplace"},"upgrade":{"crds":"CreateReplace"}}` | Flux reconciliation overrides specifically for the Jaeger Package |
| jaeger.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| jaeger.sso.enabled | bool | `false` | Toggle SSO for Jaeger on and off |
| jaeger.sso.client_id | string | `""` | OIDC Client ID to use for Jaeger |
| jaeger.sso.client_secret | string | `""` | OIDC Client Secret to use for Jaeger |
| jaeger.values | object | `{}` | Values to pass through to Jaeger chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/jaeger.git |
| jaeger.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| kiali.enabled | bool | `true` | Toggle deployment of Kiali. |
| kiali.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/core/kiali.git"` |  |
| kiali.git.path | string | `"./chart"` |  |
| kiali.git.tag | string | `"1.60.0-bb.1"` |  |
| kiali.flux | object | `{}` | Flux reconciliation overrides specifically for the Kiali Package |
| kiali.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| kiali.sso.enabled | bool | `false` | Toggle SSO for Kiali on and off |
| kiali.sso.client_id | string | `""` | OIDC Client ID to use for Kiali |
| kiali.sso.client_secret | string | `""` | OIDC Client Secret to use for Kiali |
| kiali.values | object | `{}` | Values to pass through to Kiali chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/kiali |
| kiali.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| clusterAuditor | object | `{"enabled":true,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/cluster-auditor.git","tag":"1.5.0-bb.2"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Cluster Auditor  |
| clusterAuditor.enabled | bool | `true` | Toggle deployment of Cluster Auditor. |
| clusterAuditor.flux | object | `{}` | Flux reconciliation overrides specifically for the Cluster Auditor Package |
| clusterAuditor.values | object | `{}` | Values to passthrough to the cluster auditor chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/cluster-auditor.git |
| clusterAuditor.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| gatekeeper | object | `{"enabled":true,"flux":{"install":{"crds":"CreateReplace"},"upgrade":{"crds":"CreateReplace"}},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/policy.git","tag":"3.10.0-bb.0"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- OPA Gatekeeper  |
| gatekeeper.enabled | bool | `true` | Toggle deployment of OPA Gatekeeper. |
| gatekeeper.flux | object | `{"install":{"crds":"CreateReplace"},"upgrade":{"crds":"CreateReplace"}}` | Flux reconciliation overrides specifically for the OPA Gatekeeper Package |
| gatekeeper.values | object | `{}` | Values to passthrough to the gatekeeper chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/policy.git |
| gatekeeper.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| kyverno | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno.git","tag":"2.6.5-bb.0"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Kyverno  |
| kyverno.enabled | bool | `false` | Toggle deployment of Kyverno. |
| kyverno.flux | object | `{}` | Flux reconciliation overrides specifically for the Kyverno Package |
| kyverno.values | object | `{}` | Values to passthrough to the kyverno chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno.git |
| kyverno.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| kyvernopolicies.enabled | bool | `false` | Toggle deployment of Kyverno policies |
| kyvernopolicies.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno-policies.git"` |  |
| kyvernopolicies.git.path | string | `"./chart"` |  |
| kyvernopolicies.git.tag | string | `"1.1.0-bb.0"` |  |
| kyvernopolicies.flux | object | `{}` | Flux reconciliation overrides specifically for the Kyverno Package |
| kyvernopolicies.values | object | `{}` | Values to passthrough to the kyverno policies chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno-policies.git |
| kyvernopolicies.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| kyvernoreporter.enabled | bool | `false` | Toggle deployment of Kyverno Reporter |
| kyvernoreporter.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno-reporter.git"` |  |
| kyvernoreporter.git.path | string | `"./chart"` |  |
| kyvernoreporter.git.tag | string | `"2.13.4-bb.1"` |  |
| kyvernoreporter.flux | object | `{}` | Flux reconciliation overrides specifically for the Kyverno Reporter Package |
| kyvernoreporter.values | object | `{}` | Values to passthrough to the kyverno reporter chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno-reporter.git |
| kyvernoreporter.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| logging | object | `{"enabled":true,"flux":{"timeout":"20m"},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/elasticsearch-kibana.git","tag":"0.14.2-bb.0"},"ingress":{"gateway":""},"license":{"keyJSON":"","trial":false},"postRenderers":[],"sso":{"client_id":"","client_secret":"","enabled":false},"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Logging  |
| logging.enabled | bool | `true` | Toggle deployment of Logging (EFK). |
| logging.flux | object | `{"timeout":"20m"}` | Flux reconciliation overrides specifically for the Logging (EFK) Package |
| logging.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| logging.sso.enabled | bool | `false` | Toggle OIDC SSO for Kibana/Elasticsearch on and off. Enabling this option will auto-create any required secrets. |
| logging.sso.client_id | string | `""` | Elasticsearch/Kibana OIDC client ID |
| logging.sso.client_secret | string | `""` | Elasticsearch/Kibana OIDC client secret |
| logging.license.trial | bool | `false` | Toggle trial license installation of elasticsearch.  Note that enterprise (non trial) is required for SSO to work. |
| logging.license.keyJSON | string | `""` | Elasticsearch license in json format seen here: https://repo1.dso.mil/platform-one/big-bang/apps/core/elasticsearch-kibana#enterprise-license |
| logging.values | object | `{}` | Values to passthrough to the elasticsearch-kibana chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/elasticsearch-kibana.git |
| logging.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| eckoperator.enabled | bool | `true` | Toggle deployment of ECK Operator. |
| eckoperator.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/core/eck-operator.git"` |  |
| eckoperator.git.path | string | `"./chart"` |  |
| eckoperator.git.tag | string | `"2.5.0-bb.0"` |  |
| eckoperator.flux | object | `{}` | Flux reconciliation overrides specifically for the ECK Operator Package |
| eckoperator.values | object | `{}` | Values to passthrough to the eck-operator chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/eck-operator.git |
| fluentbit.enabled | bool | `true` | Toggle deployment of Fluent-Bit. |
| fluentbit.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/core/fluentbit.git"` |  |
| fluentbit.git.path | string | `"./chart"` |  |
| fluentbit.git.tag | string | `"0.21.7-bb.0"` |  |
| fluentbit.flux | object | `{}` | Flux reconciliation overrides specifically for the Fluent-Bit Package |
| fluentbit.values | object | `{}` | Values to passthrough to the fluentbit chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/fluentbit.git |
| fluentbit.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| promtail | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/promtail.git","tag":"6.7.2-bb.0"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- BETA support of promtail/loki logging stack  |
| promtail.enabled | bool | `false` | Toggle deployment of Promtail. |
| promtail.flux | object | `{}` | Flux reconciliation overrides specifically for the Promtail Package |
| promtail.values | object | `{}` | Values to passthrough to the promtail chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/fluentbit.git |
| promtail.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| loki.enabled | bool | `false` | Toggle deployment of Loki. |
| loki.git.repo | string | `"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/loki.git"` |  |
| loki.git.path | string | `"./chart"` |  |
| loki.git.tag | string | `"3.7.0-bb.1"` |  |
| loki.flux | object | `{}` | Flux reconciliation overrides specifically for the Loki Package |
| loki.strategy | string | `"monolith"` | Loki architecture.  Options are monolith and scalable |
| loki.objectStorage.endpoint | string | `""` | S3 compatible endpoint to use for connection information. examples: "https://s3.amazonaws.com" "https://s3.us-gov-west-1.amazonaws.com" "http://minio.minio.svc.cluster.local:9000" |
| loki.objectStorage.region | string | `""` | S3 compatible region to use for connection information. |
| loki.objectStorage.accessKey | string | `""` | Access key for connecting to object storage endpoint. |
| loki.objectStorage.accessSecret | string | `""` | Secret key for connecting to object storage endpoint. Unencoded string data. This should be placed in the secret values and then encrypted |
| loki.objectStorage.bucketNames | object | `{}` | Bucket Names for the Loki buckets as YAML chunks: loki-logs ruler: loki-ruler admin: loki-admin |
| loki.values | object | `{}` | Values to passthrough to the Loki chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/loki.git |
| loki.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| neuvector | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/neuvector.git","tag":"2.4.0-bb.2"},"ingress":{"gateway":""},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- |
| neuvector.enabled | bool | `false` | Toggle deployment of Neuvector. |
| neuvector.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| neuvector.flux | object | `{}` | Flux reconciliation overrides specifically for the Neuvector Package |
| neuvector.values | object | `{}` | Values to passthrough to the Neuvector chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/neuvector.git |
| neuvector.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| tempo | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/tempo.git","tag":"0.16.1-bb.3"},"ingress":{"gateway":""},"objectStorage":{"accessKey":"","accessSecret":"","bucket":"","endpoint":"","insecure":false,"region":""},"postRenderers":[],"sso":{"client_id":"","client_secret":"","enabled":false},"values":{}}` | -------------------------------------------------------------------------------------------------------------------- |
| tempo.enabled | bool | `false` | Toggle deployment of Tempo. |
| tempo.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| tempo.flux | object | `{}` | Flux reconciliation overrides specifically for the Tempo Package |
| tempo.sso.enabled | bool | `false` | Toggle SSO for Tempo on and off |
| tempo.sso.client_id | string | `""` | OIDC Client ID to use for Tempo |
| tempo.sso.client_secret | string | `""` | OIDC Client Secret to use for Tempo |
| tempo.objectStorage.endpoint | string | `""` | S3 compatible endpoint to use for connection information. examples: "s3.amazonaws.com" "s3.us-gov-west-1.amazonaws.com" "minio.minio.svc.cluster.local:9000" Note: tempo does not require protocol prefix for URL. |
| tempo.objectStorage.region | string | `""` | S3 compatible region to use for connection information. |
| tempo.objectStorage.accessKey | string | `""` | Access key for connecting to object storage endpoint. |
| tempo.objectStorage.accessSecret | string | `""` | Secret key for connecting to object storage endpoint. Unencoded string data. This should be placed in the secret values and then encrypted |
| tempo.objectStorage.bucket | string | `""` | Bucket Name for Tempo examples: "tempo-traces" |
| tempo.objectStorage.insecure | bool | `false` | Whether or not objectStorage connection should require HTTPS, if connecting to in-cluster object storage on port 80/9000 set this value to true. |
| tempo.values | object | `{}` | Values to passthrough to the Tempo chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/tempo.git |
| tempo.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| monitoring | object | `{"enabled":true,"flux":{"install":{"crds":"CreateReplace"},"upgrade":{"crds":"CreateReplace"}},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/monitoring.git","tag":"43.1.2-bb.1"},"ingress":{"gateway":""},"postRenderers":[],"sso":{"alertmanager":{"client_id":"","client_secret":""},"enabled":false,"grafana":{"allow_sign_up":"true","client_id":"","client_secret":"","role_attribute_path":"Viewer","scopes":""},"prometheus":{"client_id":"","client_secret":""}},"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Monitoring  |
| monitoring.enabled | bool | `true` | Toggle deployment of Monitoring (Prometheus, Grafana, and Alertmanager). |
| monitoring.flux | object | `{"install":{"crds":"CreateReplace"},"upgrade":{"crds":"CreateReplace"}}` | Flux reconciliation overrides specifically for the Monitoring Package |
| monitoring.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| monitoring.sso.enabled | bool | `false` | Toggle SSO for monitoring components on and off |
| monitoring.sso.prometheus.client_id | string | `""` | Prometheus OIDC client ID |
| monitoring.sso.prometheus.client_secret | string | `""` | Prometheus OIDC client secret |
| monitoring.sso.alertmanager.client_id | string | `""` | Alertmanager OIDC client ID |
| monitoring.sso.alertmanager.client_secret | string | `""` | Alertmanager OIDC client secret |
| monitoring.sso.grafana.client_id | string | `""` | Grafana OIDC client ID |
| monitoring.sso.grafana.client_secret | string | `""` | Grafana OIDC client secret |
| monitoring.sso.grafana.scopes | string | `""` | Grafana OIDC client scopes, comma separated, see https://grafana.com/docs/grafana/latest/auth/generic-oauth/ |
| monitoring.values | object | `{}` | Values to passthrough to the monitoring chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/monitoring.git |
| monitoring.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| twistlock | object | `{"enabled":true,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/twistlock.git","tag":"0.11.4-bb.2"},"ingress":{"gateway":""},"postRenderers":[],"sso":{"cert":"","client_id":"","console_url":"https://twistlock.{{ .Values.domain }}","enabled":false,"groups":"","idp_url":"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}/protocol/saml","issuer_uri":"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}","provider_name":"","provider_type":"shibboleth"},"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Twistlock  |
| twistlock.enabled | bool | `true` | Toggle deployment of Twistlock. |
| twistlock.flux | object | `{}` | Flux reconciliation overrides specifically for the Twistlock Package |
| twistlock.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| twistlock.sso.enabled | bool | `false` | Toggle SAML SSO, requires a license and enabling the init job - see https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/twistlock/-/blob/main/docs/initialization.md |
| twistlock.sso.client_id | string | `""` | SAML client ID |
| twistlock.sso.provider_name | string | `""` | SAML Povider Alias (optional) |
| twistlock.sso.provider_type | string | `"shibboleth"` | SAML Identity Provider. `shibboleth` is recommended by Twistlock support for Keycloak |
| twistlock.sso.issuer_uri | string | `"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}"` | Identity Provider url with path to realm |
| twistlock.sso.idp_url | string | `"https://{{ .Values.sso.oidc.host }}/auth/realms/{{ .Values.sso.oidc.realm }}/protocol/saml"` | SAML Identity Provider SSO URL |
| twistlock.sso.console_url | string | `"https://twistlock.{{ .Values.domain }}"` | Console URL of the Twistlock app (optional) |
| twistlock.sso.groups | string | `""` | Groups attribute (optional) |
| twistlock.sso.cert | string | `""` | X.509 Certificate from Identity Provider (i.e. Keycloak). See https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/twistlock/-/blob/main/docs/KEYCLOAK.md for format. Use the `|-` syntax for multiline string. |
| twistlock.values | object | `{}` | Values to passthrough to the twistlock chart: https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/twistlock.git |
| twistlock.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons | object | `{"anchore":{"adminPassword":"","database":{"database":"","feeds_database":"","host":"","password":"","port":"","username":""},"enabled":false,"enterprise":{"enabled":false,"licenseYaml":"FULL LICENSE\n"},"flux":{"upgrade":{"disableWait":true}},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/anchore-enterprise.git","tag":"1.21.1-bb.0"},"ingress":{"gateway":""},"postRenderers":[],"redis":{"host":"","password":"","port":"","username":""},"sso":{"client_id":"","enabled":false,"role_attribute":""},"values":{}},"argocd":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/argocd.git","tag":"5.16.1-bb.1"},"ingress":{"gateway":""},"postRenderers":[],"redis":{"host":"","port":""},"sso":{"client_id":"","client_secret":"","enabled":false,"groups":"g, Impact Level 2 Authorized, role:admin\n","provider_name":""},"values":{}},"authservice":{"chains":{},"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/core/authservice.git","tag":"0.5.3-bb.2"},"postRenderers":[],"values":{}},"gitlab":{"database":{"database":"","host":"","password":"","port":5432,"username":""},"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/gitlab.git","tag":"6.7.0-bb.3"},"hostnames":{"gitlab":"gitlab","registry":"registry"},"ingress":{"gateway":""},"objectStorage":{"accessKey":"","accessSecret":"","bucketPrefix":"","endpoint":"","iamProfile":"","region":"","type":""},"postRenderers":[],"redis":{"password":""},"smtp":{"password":""},"sso":{"client_id":"","client_secret":"","enabled":false,"end_session_uri":"","issuer_uri":"","label":"","scopes":["Gitlab"],"uid_field":"preferred_username"},"values":{}},"gitlabRunner":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/gitlab-runner.git","tag":"0.48.2-bb.0"},"postRenderers":[],"values":{}},"haproxy":{"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/haproxy.git","tag":"1.12.0-bb.0"},"ingress":{"gateway":""},"postRenderers":[],"values":{}},"keycloak":{"database":{"database":"","host":"","password":"","port":5432,"type":"postgres","username":""},"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/keycloak.git","tag":"18.3.0-bb.2"},"ingress":{"cert":"","gateway":"passthrough","key":""},"postRenderers":[],"values":{}},"mattermost":{"database":{"database":"","host":"","password":"","port":"","ssl_mode":"","username":""},"elasticsearch":{"enabled":false},"enabled":false,"enterprise":{"enabled":false,"license":""},"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost.git","tag":"7.5.1-bb.4"},"ingress":{"gateway":""},"objectStorage":{"accessKey":"","accessSecret":"","bucket":"","endpoint":""},"postRenderers":[],"sso":{"auth_endpoint":"","client_id":"","client_secret":"","enabled":false,"token_endpoint":"","user_api_endpoint":""},"values":{}},"mattermostoperator":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost-operator.git","tag":"1.19.0-bb.0"},"postRenderers":[],"values":{}},"metricsServer":{"enabled":"auto","flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/metrics-server.git","tag":"3.8.3-bb.0"},"postRenderers":[],"values":{}},"minio":{"accesskey":"","enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/application-utilities/minio.git","tag":"4.5.4-bb.3"},"ingress":{"gateway":""},"postRenderers":[],"secretkey":"","values":{}},"minioOperator":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/application-utilities/minio-operator.git","tag":"4.5.4-bb.0"},"postRenderers":[],"values":{}},"nexusRepositoryManager":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/nexus.git","tag":"45.0.0-bb.2"},"ingress":{"gateway":""},"license_key":"","postRenderers":[],"sso":{"enabled":false,"idp_data":{"email":"","entityId":"","firstName":"","groups":"","idpMetadata":"","lastName":"","username":""},"role":[{"description":"","id":"","name":"","privileges":[],"roles":[]}]},"values":{}},"sonarqube":{"database":{"database":"","host":"","password":"","port":5432,"username":""},"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/sonarqube.git","tag":"1.0.31-bb.4"},"ingress":{"gateway":""},"postRenderers":[],"sso":{"certificate":"","client_id":"","email":"email","enabled":false,"group":"group","login":"login","name":"name","provider_name":""},"values":{}},"vault":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/vault.git","tag":"0.23.0-bb.2"},"ingress":{"cert":"","gateway":"","key":""},"postRenderers":[],"values":{}},"velero":{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/cluster-utilities/velero.git","tag":"3.1.0-bb.1"},"plugins":[],"postRenderers":[],"values":{}}}` | --------------------------------------------------------------------------------------------------------------------  |
| addons.argocd.enabled | bool | `false` | Toggle deployment of ArgoCD. |
| addons.argocd.flux | object | `{}` | Flux reconciliation overrides specifically for the ArgoCD Package |
| addons.argocd.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.argocd.redis.host | string | `""` | Hostname of a pre-existing Redis to use for ArgoCD. Entering connection info will enable external Redis and will auto-create any required secrets. |
| addons.argocd.redis.port | string | `""` | Port of a pre-existing Redis to use for ArgoCD. |
| addons.argocd.sso.enabled | bool | `false` | Toggle SSO for ArgoCD on and off |
| addons.argocd.sso.client_id | string | `""` | ArgoCD OIDC client ID |
| addons.argocd.sso.client_secret | string | `""` | ArgoCD OIDC client secret |
| addons.argocd.sso.provider_name | string | `""` | ArgoCD SSO login text |
| addons.argocd.sso.groups | string | `"g, Impact Level 2 Authorized, role:admin\n"` | ArgoCD SSO group roles, see docs for more details: https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ |
| addons.argocd.values | object | `{}` | Values to passthrough to the argocd chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/argocd.git |
| addons.argocd.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.authservice.enabled | bool | `false` | Toggle deployment of Authservice. if enabling authservice, a filter needs to be provided by either enabling sso for monitoring or istio, or manually adding a filter chain in the values here: values:   chain:     minimal:       callback_uri: "https://somecallback" |
| addons.authservice.flux | object | `{}` | Flux reconciliation overrides specifically for the Authservice Package |
| addons.authservice.values | object | `{}` | Values to passthrough to the authservice chart: https://repo1.dso.mil/platform-one/big-bang/apps/core/authservice.git |
| addons.authservice.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.authservice.chains | object | `{}` | Additional authservice chain configurations. |
| addons.minioOperator | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/application-utilities/minio-operator.git","tag":"4.5.4-bb.0"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Minio Operator and Instance  |
| addons.minioOperator.enabled | bool | `false` | Toggle deployment of minio operator and instance. |
| addons.minioOperator.flux | object | `{}` | Flux reconciliation overrides specifically for the Minio Operator Package |
| addons.minioOperator.values | object | `{}` | Values to passthrough to the minio operator chart: https://repo1.dso.mil/platform-one/big-bang/apps/application-utilities/minio-operator.git |
| addons.minioOperator.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.minio.enabled | bool | `false` | Toggle deployment of minio. |
| addons.minio.flux | object | `{}` | Flux reconciliation overrides specifically for the Minio Package |
| addons.minio.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.minio.accesskey | string | `""` | Default access key to use for minio. |
| addons.minio.secretkey | string | `""` | Default secret key to intstantiate with minio, you should change/delete this after installation. |
| addons.minio.values | object | `{}` | Values to passthrough to the minio instance chart: https://repo1.dso.mil/platform-one/big-bang/apps/application-utilities/minio.git |
| addons.minio.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.gitlab.enabled | bool | `false` | Toggle deployment of Gitlab |
| addons.gitlab.flux | object | `{}` | Flux reconciliation overrides specifically for the Gitlab Package |
| addons.gitlab.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.gitlab.sso.enabled | bool | `false` | Toggle OIDC SSO for Gitlab on and off. Enabling this option will auto-create any required secrets. |
| addons.gitlab.sso.client_id | string | `""` | Gitlab OIDC client ID |
| addons.gitlab.sso.client_secret | string | `""` | Gitlab OIDC client secret |
| addons.gitlab.sso.label | string | `""` | Gitlab SSO login button label |
| addons.gitlab.sso.scopes | list | `["Gitlab"]` | Gitlab SSO Scopes, default is ["Gitlab"] |
| addons.gitlab.sso.issuer_uri | string | `""` | GitLab SSO Issuer URI, Only needed if your SSO is non-Keycloak |
| addons.gitlab.sso.end_session_uri | string | `""` | GitLab SSO End Session URI, Only needed if your SSO is non-Keycloak |
| addons.gitlab.sso.uid_field | string | `"preferred_username"` | Gitlab SSO UID field |
| addons.gitlab.database.host | string | `""` | Hostname of a pre-existing PostgreSQL database to use for Gitlab. Entering connection info will disable the deployment of an internal database and will auto-create any required secrets. |
| addons.gitlab.database.port | int | `5432` | Port of a pre-existing PostgreSQL database to use for Gitlab. |
| addons.gitlab.database.database | string | `""` | Database name to connect to on host. |
| addons.gitlab.database.username | string | `""` | Username to connect as to external database, the user must have all privileges on the database. |
| addons.gitlab.database.password | string | `""` | Database password for the username used to connect to the existing database. |
| addons.gitlab.objectStorage.type | string | `""` | Type of object storage to use for Gitlab, setting to s3 will assume an external, pre-existing object storage is to be used. Entering connection info will enable this option and will auto-create any required secrets |
| addons.gitlab.objectStorage.endpoint | string | `""` | S3 compatible endpoint to use for connection information. examples: "https://s3.amazonaws.com" "https://s3.us-gov-west-1.amazonaws.com" "http://minio.minio.svc.cluster.local:9000" |
| addons.gitlab.objectStorage.region | string | `""` | S3 compatible region to use for connection information. |
| addons.gitlab.objectStorage.accessKey | string | `""` | If using accessKey and accessSecret, the iamProfile must be left as an empty string: "" |
| addons.gitlab.objectStorage.accessSecret | string | `""` | Secret key for connecting to object storage endpoint. Unencoded string data. This should be placed in the secret values and then encrypted |
| addons.gitlab.objectStorage.bucketPrefix | string | `""` | Bucket prefix to use for identifying buckets. Example: "prod" will produce "prod-gitlab-bucket" |
| addons.gitlab.objectStorage.iamProfile | string | `""` | If using an AWS IAM profile, the accessKey and accessSecret values must be left as empty strings eg: "" |
| addons.gitlab.smtp.password | string | `""` | Passwords should be placed in an encrypted file. Example: environment-bb-secret.enc.yaml If a value is provided BigBang will create a k8s secret named gitlab-smtp-password in the gitlab namespace |
| addons.gitlab.redis.password | string | `""` | This needs to be set to a non-empty value in order for the Grafana Redis Datasource and Dashboards to be installed. |
| addons.gitlab.values | object | `{}` | Values to passthrough to the gitlab chart: https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/gitlab.git |
| addons.gitlab.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.gitlabRunner.enabled | bool | `false` | Toggle deployment of Gitlab Runner |
| addons.gitlabRunner.flux | object | `{}` | Flux reconciliation overrides specifically for the Gitlab Runner Package |
| addons.gitlabRunner.values | object | `{}` | Values to passthrough to the gitlab runner chart: https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/gitlab-runner.git |
| addons.gitlabRunner.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.nexusRepositoryManager.enabled | bool | `false` | Toggle deployment of Nexus Repository Manager. |
| addons.nexusRepositoryManager.license_key | string | `""` | Base64 encoded license file. |
| addons.nexusRepositoryManager.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.nexusRepositoryManager.sso.enabled | bool | `false` | https://support.sonatype.com/hc/en-us/articles/1500000976522-SAML-integration-for-Nexus-Repository-Manager-Pro-3-and-Nexus-IQ-Server-with-Keycloak#h_01EV7CWCYH3YKAPMAHG8XMQ599 |
| addons.nexusRepositoryManager.sso.idp_data | object | `{"email":"","entityId":"","firstName":"","groups":"","idpMetadata":"","lastName":"","username":""}` | NXRM SAML SSO Integration data |
| addons.nexusRepositoryManager.sso.idp_data.username | string | `""` | NXRM username attribute |
| addons.nexusRepositoryManager.sso.idp_data.firstName | string | `""` | NXRM firstname attribute (optional) |
| addons.nexusRepositoryManager.sso.idp_data.lastName | string | `""` | NXRM lastname attribute (optional) |
| addons.nexusRepositoryManager.sso.idp_data.email | string | `""` | NXRM email attribute (optional) |
| addons.nexusRepositoryManager.sso.idp_data.groups | string | `""` | NXRM groups attribute (optional) |
| addons.nexusRepositoryManager.sso.idp_data.idpMetadata | string | `""` | this information is public and does not require a secret |
| addons.nexusRepositoryManager.sso.role | list | `[{"description":"","id":"","name":"","privileges":[],"roles":[]}]` | NXRM Role |
| addons.nexusRepositoryManager.flux | object | `{}` | Flux reconciliation overrides specifically for the Nexus Repository Manager Package |
| addons.nexusRepositoryManager.values | object | `{}` | Values to passthrough to the nxrm chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/nexus.git |
| addons.nexusRepositoryManager.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.sonarqube.enabled | bool | `false` | Toggle deployment of SonarQube. |
| addons.sonarqube.flux | object | `{}` | Flux reconciliation overrides specifically for the Sonarqube Package |
| addons.sonarqube.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.sonarqube.sso.enabled | bool | `false` | Toggle SAML SSO for SonarQube. Enabling this option will auto-create any required secrets. |
| addons.sonarqube.sso.client_id | string | `""` | SonarQube SAML client ID |
| addons.sonarqube.sso.provider_name | string | `""` | SonarQube SSO login button label |
| addons.sonarqube.sso.certificate | string | `""` | SonarQube plaintext SAML sso certificate. example: MITCAYCBFyIEUjNBkqhkiG9w0BA.... |
| addons.sonarqube.sso.login | string | `"login"` | SonarQube login sso attribute. |
| addons.sonarqube.sso.name | string | `"name"` | SonarQube name sso attribute. |
| addons.sonarqube.sso.email | string | `"email"` | SonarQube email sso attribute. |
| addons.sonarqube.sso.group | optional | `"group"` | SonarQube group sso attribute. |
| addons.sonarqube.database.host | string | `""` | Hostname of a pre-existing PostgreSQL database to use for SonarQube. |
| addons.sonarqube.database.port | int | `5432` | Port of a pre-existing PostgreSQL database to use for SonarQube. |
| addons.sonarqube.database.database | string | `""` | Database name to connect to on host. |
| addons.sonarqube.database.username | string | `""` | Username to connect as to external database, the user must have all privileges on the database. |
| addons.sonarqube.database.password | string | `""` | Database password for the username used to connect to the existing database. |
| addons.sonarqube.values | object | `{}` | Values to passthrough to the sonarqube chart: https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/sonarqube.git |
| addons.sonarqube.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.haproxy | object | `{"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/haproxy.git","tag":"1.12.0-bb.0"},"ingress":{"gateway":""},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Deployment of HAProxy is automatically toggled depending on Monitoring SSO and Monitoring Istio Injection  |
| addons.haproxy.flux | object | `{}` | Flux reconciliation overrides specifically for the HAProxy Package |
| addons.haproxy.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.haproxy.values | object | `{}` | Values to passthrough to the haproxy chart: https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/haproxy.git |
| addons.haproxy.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.anchore.enabled | bool | `false` | Toggle deployment of Anchore. |
| addons.anchore.flux | object | `{"upgrade":{"disableWait":true}}` | Flux reconciliation overrides specifically for the Anchore Package |
| addons.anchore.adminPassword | string | `""` | Initial admin password used to authenticate to Anchore. |
| addons.anchore.enterprise | object | `{"enabled":false,"licenseYaml":"FULL LICENSE\n"}` | Anchore Enterprise functionality. |
| addons.anchore.enterprise.enabled | bool | `false` | Toggle the installation of Anchore Enterprise.  This must be accompanied by a valid license. |
| addons.anchore.enterprise.licenseYaml | string | `"FULL LICENSE\n"` | License for Anchore Enterprise. For formatting examples see https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/anchore-enterprise/-/blob/main/docs/CHART.md#enabling-enterprise-services |
| addons.anchore.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.anchore.sso.enabled | bool | `false` | Toggle OIDC SSO for Anchore on and off. Enabling this option will auto-create any required secrets (Note: SSO requires an Enterprise license). |
| addons.anchore.sso.client_id | string | `""` | Anchore OIDC client ID |
| addons.anchore.sso.role_attribute | string | `""` | Anchore OIDC client role attribute |
| addons.anchore.database.host | string | `""` | Hostname of a pre-existing PostgreSQL database to use for Anchore. Entering connection info will disable the deployment of an internal database and will auto-create any required secrets. |
| addons.anchore.database.port | string | `""` | Port of a pre-existing PostgreSQL database to use for Anchore. |
| addons.anchore.database.username | string | `""` | Username to connect as to external database, the user must have all privileges on the database. |
| addons.anchore.database.password | string | `""` | Database password for the username used to connect to the existing database. |
| addons.anchore.database.database | string | `""` | Database name to connect to on host (Note: database name CANNOT contain hyphens). |
| addons.anchore.database.feeds_database | string | `""` | Feeds database name to connect to on host (Note: feeds database name CANNOT contain hyphens). Only required for enterprise edition of anchore. By default, feeds database will be configured with the same username and password as the main database. For formatting examples on how to use a separate username and password for the feeds database see https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/anchore-enterprise/-/blob/main/docs/CHART.md#handling-dependencies |
| addons.anchore.redis.host | string | `""` | Hostname of a pre-existing Redis to use for Anchore Enterprise. Entering connection info will enable external redis and will auto-create any required secrets. Anchore only requires redis for enterprise deployments and will not provision an instance if using external |
| addons.anchore.redis.port | string | `""` | Port of a pre-existing Redis to use for Anchore Enterprise. |
| addons.anchore.redis.username | string | `""` | OPTIONAL: Username to connect to a pre-existing Redis (for password-only auth leave empty) |
| addons.anchore.redis.password | string | `""` | Password to connect to pre-existing Redis. |
| addons.anchore.values | object | `{}` | Values to passthrough to the anchore chart: https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/anchore-enterprise.git |
| addons.anchore.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.mattermostoperator | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost-operator.git","tag":"1.19.0-bb.0"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Mattermost Operator and Instance  |
| addons.mattermostoperator.flux | object | `{}` | Flux reconciliation overrides specifically for the Mattermost Operator Package |
| addons.mattermostoperator.values | object | `{}` | Values to passthrough to the mattermost operator chart: https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost-operator/-/blob/main/chart/values.yaml |
| addons.mattermostoperator.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.mattermost.enabled | bool | `false` | Toggle deployment of Mattermost. |
| addons.mattermost.flux | object | `{}` | Flux reconciliation overrides specifically for the Mattermost Package |
| addons.mattermost.enterprise | object | `{"enabled":false,"license":""}` | Mattermost Enterprise functionality. |
| addons.mattermost.enterprise.enabled | bool | `false` | Toggle the Mattermost Enterprise.  This must be accompanied by a valid license unless you plan to start a trial post-install. |
| addons.mattermost.enterprise.license | string | `""` | License for Mattermost. This should be the entire contents of the license file from Mattermost (should be one line), example below license: "eyJpZCI6InIxM205bjR3eTdkYjludG95Z3RiOD---REST---IS---HIDDEN |
| addons.mattermost.ingress | object | `{"gateway":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.mattermost.sso.enabled | bool | `false` | Toggle OIDC SSO for Mattermost on and off. Enabling this option will auto-create any required secrets. |
| addons.mattermost.sso.client_id | string | `""` | Mattermost OIDC client ID |
| addons.mattermost.sso.client_secret | string | `""` | Mattermost OIDC client secret |
| addons.mattermost.sso.auth_endpoint | string | `""` | Mattermost OIDC auth endpoint To get endpoint values, see here: https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost/-/blob/main/docs/keycloak.md#helm-values |
| addons.mattermost.sso.token_endpoint | string | `""` | Mattermost OIDC token endpoint To get endpoint values, see here: https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost/-/blob/main/docs/keycloak.md#helm-values |
| addons.mattermost.sso.user_api_endpoint | string | `""` | Mattermost OIDC user API endpoint To get endpoint values, see here: https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost/-/blob/main/docs/keycloak.md#helm-values |
| addons.mattermost.database.host | string | `""` | Hostname of a pre-existing PostgreSQL database to use for Mattermost. Entering connection info will disable the deployment of an internal database and will auto-create any required secrets. |
| addons.mattermost.database.port | string | `""` | Port of a pre-existing PostgreSQL database to use for Mattermost. |
| addons.mattermost.database.username | string | `""` | Username to connect as to external database, the user must have all privileges on the database. |
| addons.mattermost.database.password | string | `""` | Database password for the username used to connect to the existing database. |
| addons.mattermost.database.database | string | `""` | Database name to connect to on host. |
| addons.mattermost.database.ssl_mode | string | `""` | SSL Mode to use when connecting to the database. Allowable values for this are viewable in the postgres documentation: https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-SSLMODE-STATEMENTS |
| addons.mattermost.objectStorage.endpoint | string | `""` | S3 compatible endpoint to use for connection information. Entering connection info will enable this option and will auto-create any required secrets. examples: "s3.amazonaws.com" "s3.us-gov-west-1.amazonaws.com" "minio.minio.svc.cluster.local:9000" |
| addons.mattermost.objectStorage.accessKey | string | `""` | Access key for connecting to object storage endpoint. |
| addons.mattermost.objectStorage.accessSecret | string | `""` | Secret key for connecting to object storage endpoint. Unencoded string data. This should be placed in the secret values and then encrypted |
| addons.mattermost.objectStorage.bucket | string | `""` | Bucket name to use for Mattermost - will be auto-created. |
| addons.mattermost.elasticsearch | object | `{"enabled":false}` | Mattermost Elasticsearch integration - requires enterprise E20 license - https://docs.mattermost.com/deployment/elasticsearch.html Connection info defaults to the BB deployed Elastic, all values can be overridden via the "values" passthrough for other connections. See values spec in MM chart "elasticsearch" yaml block - https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost/-/blob/main/chart/values.yaml |
| addons.mattermost.elasticsearch.enabled | bool | `false` | Toggle interaction with Elastic for optimized search indexing |
| addons.mattermost.values | object | `{}` | Values to passthrough to the Mattermost chart: https://repo1.dso.mil/platform-one/big-bang/apps/collaboration-tools/mattermost/-/blob/main/chart/values.yaml |
| addons.mattermost.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.velero.enabled | bool | `false` | Toggle deployment of Velero. |
| addons.velero.flux | object | `{}` | Flux reconciliation overrides specifically for the Velero Package |
| addons.velero.plugins | list | `[]` | Plugin provider for Velero - requires at least one plugin installed. Current supported values: aws, azure, csi |
| addons.velero.values | object | `{}` | Values to passthrough to the Velero chart: https://repo1.dso.mil/platform-one/big-bang/apps/cluster-utilities/velero/-/blob/main/chart/values.yaml |
| addons.velero.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.keycloak | object | `{"database":{"database":"","host":"","password":"","port":5432,"type":"postgres","username":""},"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/keycloak.git","tag":"18.3.0-bb.2"},"ingress":{"cert":"","gateway":"passthrough","key":""},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Keycloak  |
| addons.keycloak.enabled | bool | `false` | Toggle deployment of Keycloak. if you enable Keycloak you should uncomment the istio passthrough configurations above istio.ingressGateways.passthrough-ingressgateway and istio.gateways.passthrough |
| addons.keycloak.database.host | string | `""` | Hostname of a pre-existing database to use for Keycloak. Entering connection info will disable the deployment of an internal database and will auto-create any required secrets. |
| addons.keycloak.database.type | string | `"postgres"` | Pre-existing database type (e.g. postgres) to use for Keycloak. |
| addons.keycloak.database.port | int | `5432` | Port of a pre-existing database to use for Keycloak. |
| addons.keycloak.database.database | string | `""` | Database name to connect to on host. |
| addons.keycloak.database.username | string | `""` | Username to connect as to external database, the user must have all privileges on the database. |
| addons.keycloak.database.password | string | `""` | Database password for the username used to connect to the existing database. |
| addons.keycloak.flux | object | `{}` | Flux reconciliation overrides specifically for the OPA Gatekeeper Package |
| addons.keycloak.ingress | object | `{"cert":"","gateway":"passthrough","key":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.keycloak.ingress.key | string | `""` | Certificate/Key pair to use as the certificate for exposing Keycloak Setting the ingress cert here will automatically create the volume and volumemounts in the Keycloak Package chart |
| addons.keycloak.values | object | `{}` | Values to passthrough to the keycloak chart: https://repo1.dso.mil/platform-one/big-bang/apps/security-tools/keycloak.git |
| addons.keycloak.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.vault | object | `{"enabled":false,"flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/vault.git","tag":"0.23.0-bb.2"},"ingress":{"cert":"","gateway":"","key":""},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Vault  |
| addons.vault.enabled | bool | `false` | Toggle deployment of Vault. |
| addons.vault.flux | object | `{}` | Flux reconciliation overrides specifically for the Vault Package |
| addons.vault.ingress | object | `{"cert":"","gateway":"","key":""}` | Redirect the package ingress to a specific Istio Gateway (listed in `istio.gateways`).  The default is "public". |
| addons.vault.ingress.key | string | `""` | Certificate/Key pair to use as the certificate for exposing Vault Setting the ingress cert here will automatically create the volume and volumemounts in the Vault package chart |
| addons.vault.values | object | `{}` | Values to passthrough to the vault chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/vault.git |
| addons.vault.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |
| addons.metricsServer | object | `{"enabled":"auto","flux":{},"git":{"path":"./chart","repo":"https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/metrics-server.git","tag":"3.8.3-bb.0"},"postRenderers":[],"values":{}}` | -------------------------------------------------------------------------------------------------------------------- Metrics Server  |
| addons.metricsServer.enabled | string | `"auto"` | Toggle deployment of metrics server Acceptable options are enabled: true, enabled: false, enabled: auto true = enabled / false = disabled / auto = automatic (Installs only if metrics API endpoint is not present) |
| addons.metricsServer.flux | object | `{}` | Flux reconciliation overrides specifically for the metrics server Package |
| addons.metricsServer.values | object | `{}` | Values to passthrough to the metrics server chart: https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/metrics-server.git |
| addons.metricsServer.postRenderers | list | `[]` | Post Renderers.  See docs/postrenders.md |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

