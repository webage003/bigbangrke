# Kubernetes Cluster Preconfigured:         

## Kubernetes Best Practices:        
* All Kubernetes Nodes and the LB associated with the kube-apiserver should all use private IPs.
* In most case User Application Facing LBs should have Private IP Addresses and be paired with a defense in depth Ingress Protection mechanism like [P1's CNAP](https://p1.dso.mil/#/products/cnap/), a CNAP equivalent, VPN, VDI, port forwarding through a bastion, or air gap deployment. 
* Make sure CoreDNS in the kube-system namespace is HA with pod anti-affinity rules, master nodes are HA and tainted. 

## BigBang Specific Preconfiguration requirements: 
### BigBang doesn't support PSPs (Pod Security Policies)
* [PSP's are being removed from Kubernetes and will be gone by version 1.25.x](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/issues/10), thus we recommened users disable them: 
   ```bash
   kubectl patch psp system-unrestricted-psp -p '{"metadata": {"annotations":{"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "*"}}}'
   kubectl patch psp global-unrestricted-psp -p '{"metadata": {"annotations":{"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "*"}}}'
   kubectl patch psp global-restricted-psp -p '{"metadata": {"annotations":{"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "*"}}}'
   ```
* BigBang Deploys OpenPolicyAgent Gatekeeper with some default policies configured that default to dryrun/log only. 
  * Users are expected to configure OPA GK to their needs.
  * If users find they need the functionality of PSPs, the user can import [OPA policies that have a near 1:1 mapping to the functionality offered by PSPs.](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy#pod-security-policies)

