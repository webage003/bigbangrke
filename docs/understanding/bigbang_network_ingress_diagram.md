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
* Notice: These notes reflect a normal deployment, varitions will causef
1. Git Repo: 

2. CNAP (Cloud Native Access Point) or Equivalent Edge LB: 
Load Balancer at the Edge:      
* The istio-ingressgateway A Cloud Service Provider Load Balancer 
* 443 of this Cloud Service Provider Load Balancer (CSP LB) is load balanced between a NodePort of the worker nodes, kubeproxy then maps the NodePort to 443 of Istio Ingress Gateway, which uses Envoy as a Inner Cluster Layer 7 LB that can expose the services running in the cluster. 
* By default BB UHC leverages a single CSP LB, and uses SSO groups + authentication proxy to separate user and admin traffic.

3. Ingress LB

4. Mutating Admission Controllers
* istiod pod hosts this functionality

5. Validating Admission Controllers
Open Policy Agent Gatekeeper and Twistlock can be used as Validating Admission Controls; however, by default Twistlock is disabled as it requires a license and OPA GK defaults to dryrun/warning vs blocking/enforcing. 

6. SSO Provider
https://login.dso.mil/auth/realms/baby-yoda/
P1's Keycloak SSO:
* .mil and whitelisted domains can self register
* Federates the x509 certs associated with CAC Cards
General Flow:
. Human visits: https://grafana.bigbang.dev
. Istio-Ingress Gateway Directs them to Auth Service
. Auth Service Directs them to https://login.dso.mil
. User logins in and if they're in the correct authorization group/should have rights to see the backend, baby yoda gives user a cookie and redirects them to their original destination
. Now when user is directed to the auth service proxy, because they have cookie, they can go on to their destination.

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
