# Edge

Currently conceptual, this initiative is being added to collaborate, define, scope and identify requirements for a BB 'Near Edge' MVP. Please contribute!

## Edge is currently discussed in one of three categories

* Tiny Edge: (define)
* Far Edge: (define) 
* Near Edge: (define)

### Tiny Edge 

* Potential Future Development: this conceptual state is blocked by the dependency of ARM images in Iron Bank.

### Near Edge / Far Edge (MVP)

* Far edge may / may not require ARM containers. Recommend MVP consider x86 far edge, or consider additional terminology (i.e. tactical edge) to indicate non-ARM forward capability.

* Should this be initially resourced as a hub/spoke deployment of BB Core with resource room for mission apps?
  * We need to break out hub and spoke resources separately 
  * We could define ```hub``` as near edge and ```spoke``` as tactical or far edge.

#### Hub Resource Requirements (include hardware recommendations?)
  * CPU (x86 / how fast?)
  * Memory (how much?)
  * k8s
  * BB Core (specific packages)
  * non-HA (HA can be a future iteration / discussion?)
  * What packages are included in the base 'Near Edge' Deployment?

#### Hub Package-Specific Resource Requirements
  * Collect resources from current implementations
##### Istio
  * CPU
  * Memory 

##### Cluster Auditor
  * CPU
  * Memory 

##### OPA Gatekeeper
  * CPU
  * Memory

##### Fluentbit(logging)?
  * CPU
  * Memory

##### Prometheus
  * CPU
  * Memory

##### Grafana
  * CPU
  * Memory

##### Twistlock
  * CPU
  * Memory

##### Flux
  * CPU
  * Memory

##### Utility Server (Git and Registry)
  * CPU
  * Memory 

#### Image Packaging / Deployment

* Image Packaging
  * 
* Dependencies
  * 
* Deliverables
  * 

* Image Deployment

* Dependencies
  * 
* Deliverables
  * 

### Repository Packaging / Deployment

Near Edge Deployment is a form of deployment which may or may not have a direct connection to the Internet or external network during cluster setup or runtime. During installation, bigbang requires certain images and git repositories for installation. Since we will be installing in internet-disconnected environment, we need to perform extra steps to make sure these resources are available.

### General Prerequisites

* A kubernetes cluster with container mirroring support. There is a section below that covers mirroring in more detail with examples for supported clusters.
* BigBang(BB) [release artifacts](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/releases).
* Utility Server.
