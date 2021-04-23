# Useful Background Contextual Information: 


## The purpose of this section is to help consumers of BigBang understand:
* BigBang's scope: what it is and isn't, goals and non-goals
* The value add gained by using BigBang
* What to expect in terms of prerequisites for those interested in using BigBang
* Help those who want a deep drive concrete understanding of BigBang quickly come up to speed, via pre-reading materials, that can act as a self service new user orientation to point out features and nuances that new users wouldn't know to ask about. 


## BigBang's scope: what it is and isn't, goals and non-goals 
### What BigBang is:
* BigBang is a Helm Chart that is used to deploy a DevSecOps Platform composed of IronBank hardened container images on a Kubernetes Cluster.
* See [/docs/README.md](../README.md#what-is-bigbang?) more details.

### What BigBang isn't:
* BigBang by itself is not intended to be an End to End Secure Kubernetes Cluster Solution, but rather a reusable secure component/piece of a full solution. 
* A Secure Kubernetes Cluster Solution, will have multiple components, that can each be swapable and in some cases considered optional depending on use case and risk tolerance: 
  Example of some potential components in a full End to End Solution: 
  * P1's Cloud Native Access Point to protect Ingress Traffic. (This can be swapped with an equivalent, or considered optional in an internet disconnected setup.)
  * Hardened Host OS
  * Hardened Kubernetes Cluster (BigBang assumes ByoC, Bring your own Cluster)
  * Hardened Applications running on the Cluster (BigBang helps solve this component)


## Value add gained by using BigBang: 
* Compliant with the [DoD DevSecOps Reference Architecture Design](https://dodcio.defense.gov/Portals/0/Documents/DoD%20Enterprise%20DevSecOps%20Reference%20Design%20v1.0_Public%20Release.pdf)
* Can be used to check some but not all of the boxes needed to achieve a cATO (Continuous Authority to Operate.)
* Uses hardened IronBank Container Images. (left shifted security concern)
* Lowers maintainability overhead involved in keeping the images of the DevSecOps Platform's up to date and maintaining a secure posture over the long term. This is achieved by pairing the GitOps pattern with the Umbrella Helm Chart Pattern.        
  Let's walk through an example:       
  * Initially a kustomization.yaml file in a git repo will tell the Flux GitOps operator (software deployment bot running in the cluster), to deploy version 1.0.0 of BigBang. BigBang could deploy 10 helm charts. And each helm chart could deploy 10 images. (So BigBang is managing 100 container images in this example.)
  * After a 2 week sprint version 1.1.0 of BigBang is released. A BigBang consumer updates the kustomization.yaml file in their git repo to point to version 1.1.0 of the BigBang Helm Chart. That triggers an update of 10 helm charts to a new version of the helm chart. Each updated helm chart will point to newer versions of the container images managed by the helm chart. 
  * So when the end user edits the version of 1 kustomization.yaml file, that triggers a chain reaction that updates 100 container images. 
  * These upgrades are pre-tested. The BigBang team "eats our own dogfood". Our CI jobs for developing the BigBang product, run against a BigBang dogfood Cluster, and as part of our release process we upgrade our dogfood cluster, before publishing each release. (Note: We don't test upgrades that skip multiple minor versions.)
* Auto Update support to help with Zero Day Vulnerabilities:       
Normally consumers of BigBang should update every 2 weeks (our release cadence). In the event of zero day vulnerabilities, the BigBang team can push a mid-sprint patch release. Consumers of BigBang interested in Zero Day Vulnerability auto updates can set their kustomization.yaml to 1.1.x (We follow semantic versioning which means that the x in 1.1.x represents a backwords compatible safe security patch update). Flux understands semantic versioning and can auto update to the latest patch release as soon as it's available. 
* DoD Software Developers get a Developer User Experience of "SSO for free". Instead of developers coding SSO support 10 times for 10 apps. The complexity of SSO support is baked into the platform, and after an Ops team correctly configures the Platform's SSO settings, SSO works for all apps hosted on the platform. The developer's user experience for enabling SSO for their app then becomes as simple as adding the label istio-injection=enabled (which transparently injects mTLS service mesh protection into their application's Kubernetes YAML manifest) and adding the label protect=keycloak to each pod, which leverages an EnvoyFilter CustomResource to auto inject an SSO Authentication Proxy in front of the data path to get to their application. 





