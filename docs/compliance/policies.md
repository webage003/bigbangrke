# Policies

## Kubernetes Hardening Guide

Evaluated against [Kubernetes Hardening Guidance S/N U/OO/168286-21 PP-21-1104 Version 1.0](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)

### Core

| Name                                                              | Gatekeeper | Istio | EK Operator | Elasticsearch Kibana | Fluentbit                                                  | Monitoring | Twistlock |
| ----------------------------------------------------------------- | ---------- | ----- | ----------- | -------------------- | ---------------------------------------------------------- | ---------- | --------- |
| [No Root](#no-root)                                               | Yes        | Yes   | Yes         | Yes                  | Yes                                                        | yes        |
| [No Privileged Containers](#no-privileged-containers)             | Yes        | Yes   | Yes         | Yes                  | Fluentbit Daemonset requires Priv for collecting node logs | yes        |           |
| [Immutable Container Filesystem](#immutable-container-filesystem) |
| [Secure Images](#secuire-images)                                  |
| [HostPID](#host-pid)                                              |
| [Host IPC](#host-ipc)                                             |
| [hostNetwork](#host-network)                                      |
| [allowedHostPaths](#allowed-host-paths)                           |
| [runAsUser](#runAsUser)                                           |
| [runAsGroup](#runAsGroup)                                         |
| [suppliementalGroups](#suppliementalGroups)                       |
| [fsGroups](#fsGroups)                                             |
| [allowedPrivilegeEscalation](#allowedPrivilegeEscalation)         |
| [ App Armor Annotations](#app-armor-annotations)                  |
| [ selinux ](#seLinux)                                             |
| [ hostMounts](#hostMounts)                                        |
| [Seccomp Annotations](#app-armor-annotations)                     |

### Requirements

#### No Root (p.7)

container engines allow containers to run applications as a
non-root user with non-root group membership. Typically, this non-default setting is
configured when the container image is built. Alternatively, Kubernetes can load containers into a Pod with
SecurityContext:runAsUser specifying a non-zero user. While the runAsUser
directive effectively forces non-root execution at deployment, NSA and CISA
encourage developers to build container applications to execute as a non-root user.
Having non-root execution integrated at build time provides better assurance that
applications will function correctly without root privileges. From: [Kubernetes Hardening Guide](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)

How we check



#### Immutable Container Filesystem (p.8)

By default, containers are permitted mostly unrestricted execution within their own
context. A cyber actor who has gained execution in a container can create files,
download scripts, and modify the application within the container. Kubernetes can lock
down a container’s file system, thereby preventing many post-exploitation activities.
However, these limitations also affect legitimate container applications and can
potentially result in crashes or anomalous behavior. To prevent damaging legitimate
applications, Kubernetes administrators can mount secondary read/write file systems for
specific directories where applications require write access. From: [Kubernetes Hardening Guide](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)

BigBang valides this at runtime with the Gatekeeper policy here: https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/readOnlyRoot.yaml

#### Secure Images (p.8)

Building secure container images
Container images are usually created by either building a container from scratch or by
building on top of an existing image pulled from a repository. In addition to using trusted
repositories to build containers, image scanning is key to ensuring deployed containers
are secure. Throughout the container build workflow, images should be scanned to
identify outdated libraries, known vulnerabilities, or misconfigurations, such as insecure
ports or permissions. From: [Kubernetes Hardening Guide](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)

How we check: IronBank images are built with the best practices of the DoD and hardening guide. By
ensuring that the BigBang components deploy only IronBank images, as currently identified by their registry,
we're able to ensure that BigBang uses Secure Images. Future work will confirm this cryptographically.

#### Pod Security Policies (p.10)

[Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) were deprecated in Kubernetes v1.21 and will be removed in Kubernetes v1.25.  Instead of implementing deprecated PSPs, Big Bang is using an external admission controller, OPA Gatekeeper, to enforce the policies listed in this section.

#### No Privileged Containers (p.10, table 1)

Controls whether Pods can run privileged Containers which have increased access to kernel calls.

BigBang validates this at runtime with the Gatekeeper policy here: https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/noPrivilegedContainers.yaml

##### HostPID (p.10, table 1)

##### Host IPC (p.10, table 1)

##### hostNetwork (p.10, table 1)

https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/hostNetworking.yaml

##### allowedHostPaths (p.10, table 1)

##### readOnlyRootFilesystem (p.10, table 1)

##### runAsUser (p.10, table 1)

##### runAsGroup (p.10, table 1)

##### supplementalGroups (p.10, table 1)

##### fsGroups (p.10, table 1)

##### allowedPrivilegeEscalation (p.11, table 1)

##### seLinux (p.11, table 1)

##### AppArmor Annotations (p.11, table 1)

##### seccomp Annotations (p.11, table 1)

#### Service Account Tokens (p.11)

#### Hardened Container Engines (p.12)

Big Bang's scope does not include deploying the Kubernetes cluster or container engine.  It relies on the cluster administrator to deploy a secure configuration using best practices.
#### hostMounts

https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/allowedHostFilesystem.yaml

#### Network/Namespace Isolation (p.13)

#### Network Policies (p.14)

##### Ingress (p.14)

##### Egress (p.14)

##### External IPs (p.14)

#### Resource Policies (p.14)

#### Control Plane (p.15)

Big Bang's scope does not include deploying the Kubernetes cluster or container engine.  It relies on the cluster administrator to deploy a secure configuration using best practices.

#### Worker Node Segmentation (p.16)

Big Bang's scope does not include deploying the Kubernetes cluster or container engine.  It relies on the cluster administrator to deploy a secure configuration using best practices.

#### Encryption (p.17)

#### Secrets (p.17)

#### Sensitive Cloud Infrastructure (p.18)

Big Bang's scope does not include deploying the Kubernetes cluster or container engine.  It relies on the cluster administrator to deploy a secure configuration using best practices.

#### Authentication (p.19)

#### Role-Based Access Control (p.20)

#### Logging (p.21)

##### API Request History (p.22)

##### Performance Metrics (p.22)

##### Deployments (p.22)

##### Resource Consumption (p.22)

##### Operating System Calls (p.22)

##### Protocols, Permission Changes (p.22)

##### Network Traffic (p.22)

##### Pod Scaling (p.23)

##### Pod Creation and Updates (p.23)

##### Audits (p.23)

Big Bang's scope does not include auditing RBAC or logs.  It relies on the cluster administrator to conduct these audits.

##### External Logging Service (SIEM) (p.23/p.27)

##### Kubernetes Native Audit Logging (p.24)

##### Worker Node Logging (p.25)

##### System Calls (Seccomp) Logging (p.26)

##### SysLog (p.27)

#### SIEM (p.27)

See External Logging Service above.

#### Alerting (p.28)

##### Low Disk Space (p.28)

##### Low Storage Space on Volume (p.28)

##### Unavailble Logging Service (p.28)

##### Pod Running as Root (Privileged) (p.28)

##### Unauthorized Requests (p.28)

##### Anonymous Account Privileges (p.28)

##### Pods Created from a Pod or Node IP (p.28)

##### Unusual System Calls (p.28)

##### Failed API Calls (p.28)

##### Unusual Access Time (p.28)

##### Unusual Access Location (p.28)

##### Deviation from Standard Metrics (p.28)

#### Service Mesh (p.29)

#### Fault Tolerance (p.30)

#### Tools (p.31)

#### Upgrading and Application Security Practices (p.32)


