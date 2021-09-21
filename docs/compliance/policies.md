# Policies

## Kubernetes Hardening Guide

### Core

| Policy Name             | Description                                                | Implementation                            |
| ----------------------- | ---------------------------------------------------------- | ----------------------------------------- |
| [No Root](#no-root)     | STIG                                                       | Pods should not be allowed to Run as root |
| No Host Mounts          | Pods should not be allowed to mount underlying file system |                                           |
| No Host Networking      | Pods should not be allowed to mount the host network       | l                                         |
| No PrivilegedContainers | Pods should not have access to additional Kernel functions |                                           |

## Core

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

| [ App Armor Annotations](#app-armor-annotations)
| [ selinux ](#seLinux)
| [ hostMounts](#hostMounts)
| [Seccomp Annotations](#app-armor-annotations)

### Requirements

#### No Root

container engines allow containers to run applications as a
non-root user with non-root group membership. Typically, this non-default setting is
configured when the container image is built. Alternatively, Kubernetes can load containers into a Pod with
SecurityContext:runAsUser specifying a non-zero user. While the runAsUser
directive effectively forces non-root execution at deployment, NSA and CISA
encourage developers to build container applications to execute as a non-root user.
Having non-root execution integrated at build time provides better assurance that
applications will function correctly without root privileges. From: [Kubernetes Hardening Guide](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)

How we check

#### No Privileged Containers

Controls whether Pods can run privileged Containers which have increased access to kernel calls.

BigBang validates this at runtime with the Gatekeeper policy here: https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/noPrivilegedContainers.yaml

#### Immutable Container Filesystem

By default, containers are permitted mostly unrestricted execution within their own
context. A cyber actor who has gained execution in a container can create files,
download scripts, and modify the application within the container. Kubernetes can lock
down a container’s file system, thereby preventing many post-exploitation activities.
However, these limitations also affect legitimate container applications and can
potentially result in crashes or anomalous behavior. To prevent damaging legitimate
applications, Kubernetes administrators can mount secondary read/write file systems for
specific directories where applications require write access. From: [Kubernetes Hardening Guide](https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETES%20HARDENING%20GUIDANCE.PDF)

BigBang valides this at runtime with the Gatekeeper policy here: https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/readOnlyRoot.yaml

#### Secure Images

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

#### HostPID

#### Host IPC

#### hostNetwork

https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/hostNetworking.yaml

#### allowedHostPaths

#### runAsUser

#### runAsGroup

#### suppliementalGroups

#### fsGroups

#### allowedPrivilegeEscalation

#### seLinux

#### App Armor Annotations

#### seccomp Annotations

#### hostMounts

https://repo1.dso.mil/platform-one/big-bang/apps/core/policy/-/blob/main/chart/templates/constraints/allowedHostFilesystem.yaml

#### Network/Namespace Isolation
