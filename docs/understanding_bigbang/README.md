# Useful Background Contextual Information: 


## The purpose of this section is to help consumers of BigBang understand:
* BigBang's scope: what it is and isn't, goals and non-goals
* The value add gained by using BigBang
* What to expect in terms of prerequisites for those interested in using BigBang
* Help those who want a deep drive concrete understanding of BigBang quickly come up to speed, via pre-reading materials, that can act as a self service new user orientation to point out features and nuances that new users wouldn't even think to ask about. 


## BigBang's scope: what it is and isn't, goals and non-goals 
### What BigBang is:
* BigBang is a Helm Chart that is used to deploy a DevSecOps Platform composed of IronBank hardened container images on a Kubernetes Cluster.
* See [/docs/README.md](../README.md#what-is-bigbang?) more details.

### What BigBang isn't:
* BigBang by itself is not intended to be an End to End Secure Kubernetes Cluster Solution, but rather a reusable secure component of a full solution. 
* A Secure Kubernetes Cluster Solution, will have multiple components, that can each be swapable and in some cases considered optional depending on use case and risk tolerance: 
  Example of some potential components in a full End to End Solution: 
  * P1's Cloud Native Access Point to protect Ingress Traffic. (This can be swapped with an equivalent, or considered optional in an internet disconnected setup.)
  * Hardened Host OS
  * Hardened Kubernetes Cluster (BigBang assumes ByoC, Bring your own Cluster)
  * Hardened Applications running on the Cluster (BigBang helps solve this component)


## Value add gained by using BigBang: 
* (WIP)
