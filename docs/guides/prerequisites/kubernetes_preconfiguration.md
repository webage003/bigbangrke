# Kubernetes Cluster Preconfigured:         

## Kubernetes Best Practices:        
* All Kubernetes Nodes and the LB associated with the kube-apiserver should all use private IPs.
* In most case User Application Facing LBs should have Private IP Addresses and be paired with a defense in depth Ingress Protection mechanism like [P1's CNAP](https://p1.dso.mil/#/products/cnap/), a CNAP equivalent, VPN, VDI, port forwarding through a bastion, or air gap deployment. 
* Make sure CoreDNS in the kube-system namespace is HA with pod anti-affinity rules, master nodes are HA and tainted. 


## BigBang Specific Preconfiguration requirements: 
### BigBang doesn't support PSPs (Pod Security Policies)
* Open Policy Agent Gatekeeper is a core component of BigBang, which operates as an elevated  [validating admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) to audit and enforce various [constraints](https://github.com/open-policy-agent/frameworks/tree/master/constraint) on all requests sent to the kubernetes api server.
* [PSP's are being removed from Kubernetes and will be gone by version 1.25.x](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/issues/10), [OPA can also match the functionality provided by PSPs](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy#pod-security-policies), thus we recommened users disable them: 
   ```bash
   kubectl patch psp system-unrestricted-psp -p '{"metadata": {"annotations":{"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "*"}}}'
   kubectl patch psp global-unrestricted-psp -p '{"metadata": {"annotations":{"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "*"}}}'
   kubectl patch psp global-restricted-psp -p '{"metadata": {"annotations":{"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "*"}}}'
   ```
* Another way of disabling PSPs is to edit the kube-apiserver's flags (methods for doing this varry per distro.)


## Distro Specific Notes
### RKE2
* RKE2 turns PSPs on by default (see above for tips on disabling)
* RKE2 sets selinux to enforcing by default ([see os_preconfiguration.md for selinux config](os_preconfiguration.md))

Since BigBang makes several assumptions about volume and load balancing provisioning by default, it's vital that the rke2 cluster must be properly configured.  The easiest way to do this is through the in tree cloud providers, which can be configured through the `rke2` configuration file such as:

```yaml
# aws, azure, gcp, etc...
cloud-provider-name: aws

# additionally, set below configuration for private AWS endpoints, or custom regions such as (T)C2S (us-iso-east-1, us-iso-b-east-1)
cloud-provider-config: ...
```

For example, if using the aws terraform modules provided [on repo1](https://repo1.dso.mil/platform-one/distros/rancher-federal/rke2/rke2-aws-terraform), setting the variable: `enable_ccm = true` will ensure all the necessary resources tags.

In the absence of an in-tree cloud provider (such as on-prem), the requirements can be met by ensuring a default storage class and automatic load balancer provisioning exist. 



