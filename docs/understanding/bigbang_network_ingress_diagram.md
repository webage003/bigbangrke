# Goals of this Architecture Diagram: 
* Show a zoomed in view of BigBang Core
* Help new users better understand:
  * How traffic flows into the cluster
  * How BigBang is leveraging Istio Operator
  * How web sites hosted on BigBang are protected by an SSO Authentication Proxy
  * Internet vs LAN vs Inner Cluster Network
    * How sites are generally exposed via Istio Ingress Gateway
    * That sometimes there are services existing on the Inner Cluster Network that are not reachable outside of the Inner Cluster Network


## Notice:
* The intent of this Architecture Diagram is to: 
  * Act as a starting point upon which further understanding can be built
  * Improve a users understanding of BigBang components fit together, so that if the user needs to modify components or data flows to fit their usecase they'll have an idea of what the modification might look like
  * Show potential use cases for some of BigBang's core components
* This Architecture Diagram is NOT intended to:
  * Reflect an accurate default configuration
  * Perscriptively say you must do things this way 
* This Architecture Diagram should be taken with a grain of salt:       
  It's difficult to make a generic diagram with high accuracy. BigBang's Helm Values are variables, some values can produce significantly different traffic flows, the same can be said of SSO and Load Balancer Implementation options. Nuances specific to the deployment environment and hardened configurations like SELinux & Istio CNI can effect the implementation. 


![](images/bigbang_network_ingress_diagram.app.diagrams.net.png)


## Notes:  
### 1. Git Repo:  
* Can be HTTPS or SSH based, can exist on the Internet or in Private IP Space
* Argo CD / Flux CD need network access and in most cases credentials to authenticate against the repo.


### 2. CNAP or Equivalent Edge LB: 
* More details can be found on the [Ask Me Anything Slides located here](https://software.af.mil/dsop/documents/), but the CNAP is basically an advanced edge firewall.
* Platform One's CNAP involves a public Cloud Service Provider LB forwarding traffic to a Palo Alto Firewall then to an AppGate Software Defined Perimeter and then to the Private IP of a CSP LB / Ingreses LB of a Kubernetes Cluster running the BigBang Application Stack. 
* CNAP is NOT part of BigBang, and there is no hard requirement that says you need to use CNAP. 
  * In cases where users will be connecting purely over private IP space CNAP isn't needed.
  * Your own CNAP equivalent may be used in place of P1's CNAP.
  * If your DoD command is interested in leveraging P1's CNAP + P1's Common Access Card Integrated SSO with your own BigBang Cluster that can be arranged with VPC peering [this page has instructions on how to ask for more details](https://p1.dso.mil/#/services)


### 3. Ingress LB:      
* istiocontrolplane IstioOperator Custom Resource will spawn a Kubernetes service of type Load Balancer, which spawns a CSP LB. 
* Most deployments of BigBang should be configured to spawn a CSP LB with a Private IP Address.
* Traffic Flow:
  1. Port 443 of the Cloud Service Provider Load Balancer gets load balanced between a NodePort of the worker nodes. (The NodePort can be randomly generated or static, depending on helm values.)
  2. Kube Proxy then maps the NodePort, which is accessible on the Private IP Space Network, to port 443 of the istio-ingressgateway service which is accessible on the Kubernetes Inner Cluster Network. (So Kube Proxy and Node Ports are how traffic crosses the boundary from Private IP Space to Kubernetes Inner Cluster Network Space.)
  3. Istio-ingressgateway service port 443 then maps to port 8443 of istio-ingressgateway pods (they use the non-privileged port 8443, because they've gone through the IronBank Container hardening process. (That being said from the end users perspective the end user only sees 443.) use IronBank Containers.)
  4. The Istio Ingress Gateway pods are basically Envoy Proxies / Layer 7 Load Balancers that are dynamically configured using declarative Kubernetes Custom Resources managed via GitOps. These Ingress Gateway pods forward traffic to websites hosted in the BigBang Cluster / expose websites hosted in a BigBang Cluster.
* It's possible to have BigBang leverage a single CSP LB to expose both admin facing websites like kibana.bigbang.dev (*.bigbang.dev is the default helm value for websites hosted on a BigBang cluster) and user facing websites like gitlab.bigbang.dev. An SSO Authentication Proxy and Identity Provider groups can be used to make it so only users in certain groups can be routed to webpages intended for admins. 


### 4. Mutating Admission Controllers
* Istiod pod hosts this functionality of the sidecar injector webhook that mutates pod YAML to add istio init containers and envoy proxy sidecar containers to pods that need to be integrated into the service mesh. 
* It's possible to use Istio CNI plugin to eliminate the need for istio init containers.


### 5. Validating Admission Controllers
* Open Policy Agent Gatekeeper and Twistlock can be used as Validating Admission Controls; however, by default Twistlock is disabled as it requires a license and OPA GK defaults to dryrun/warning instead of blocking/enforcing. 


### 6. SSO Provider
* Note SSO Provider is not part of BigBang
* Example Scenario: 
  * Authorized User and Rando user both self register with P1 SSO https://login.dso.mil/      
  * The Authorized User either has a .mil email domain or links their CAC Card to an arbitrary email, and gets assigned a group.      
  * The other user with an arbitrary email gets put into a Randos group with limited access. 
  * Both users notice a https://confluence.il2.dso.mil link on the https://p1.dso.mil/#/products/big-bang/ website. 
  * The authorized user can access *.il2.dso.mil, repo1.dso.mil, and registry1.dso.mil
  * The rando user can't access il2, but can access repo1 and registry1.
* 1st Example Traffic Flow for someone using P1's Keycloak SSO:       
  1. Human Visits: https://grafana.bigbang.dev
  2. Istio-Ingress Gateway Directs traffic destined for that URL to the Istio Envoy Proxy of Auth Service
  3. Auth Service redirects them to https://login.dso.mil
  4. User logs in and if they're in the correct authorization group / if they should have rights to see the backend website the user will get a cookie and be redirected to the original URL which will redirect them to auth service only this time because they have a cookie it'll redirect them to their original destination. ir original destination. 
  5. Now when the user hits the auth service with the cookie they get redirected to their intended destination. 
* 2nd Example Traffic Flow for someone using P1's Keycloak SSO:       
  1. s
  2. s



7. HA Proxy
Why is HA Proxy there?
Jaeger and Kiali have a race condition that limits their ability to work with istio sidecar. 
Prometheus, AlertManager, and Grafana also had integration issues when the istio sidecar was enabled. 
We need the istio side car, because that's where EnvoyFilter injects authservice SSO authentication proxy in the data path.
As a work around for these edge cases, we have the virtual services terminate at haproxy, which has some BigBang Helm Chart dynamically generated configuration that allows it to be forwarded to the correct backend. 

8. Possible SSO Ingress Scenarios for Add On Apps: 
Not exposed and only referenced on the inner cluster network, by something like gitlab runners
Gitlab, kibana, twistlock, and others apps have built in support for SSO integration without leveraging an authentication proxy, so they're directly exposed, and SSO is setup via following SSO integration configuration docs. 
It's treated like a mission-app, where istio proxy injection is enabled and the pod is labeled protect=keycloak
If treating the app like a mission-app leads to issues HA Proxy is leveraged to workaround the issues.

9. Elastic Search

10. Cluster Auditor
(P1 Custom App that consolidates reports of Twistlock, Anchore, and other security compliance tools that each have different output data schema into Elastic Search to standardize the data schema)
