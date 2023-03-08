# Kustomize Proof of Concept

## Why?
As part of the `packages` and `wrapper` functionality - this proof of concept looks at utilizing the `kustomize` property of packages to deploy resources that are co-located with a supported "addon" chart. 

## What is the user experience?
A user declares a given support "addon" in `packages` which deploys a `kustomization` that then creates a `helmrelease`. Meaning it adds a intermediary layer for troubleshooting end-to-end reconciliation.


## How does it work?
A given supported "addon" would be declared as a package under `packages` like so:
```
packages:
  podinfo:
    enabled: true
    wrapper:
      enabled: false
    kustomize: true
    git:
      repo: https://repo1.dso.mil/big-bang/apps/sandbox/podinfo.git
      tag: null
      branch: "kustom_podinfo"
      path: kustomize
```

As note above - wrapper would be disabled (this might be the default in the future) - and 


A package that supports this proof of concept would look something like:

```
podinfo
├── CHANGELOG.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── chart
│   ├── Chart.yaml
│   ├── Kptfile
│   ├── LICENSE
│   ├── README.md
│   ├── charts
│   │   └── gluon-0.2.10.tgz
│   ├── dashboards
│   ├── requirements.lock
│   ├── templates
│   │   ├── NOTES.txt
│   │   ├── _helpers.tpl
│   │   ├── bigbang
│   │   │   ├── dashboards.yaml
│   │   │   └── virtualservice.yaml
│   │   ├── certificate.yaml
│   │   ├── deployment.yaml
│   │   ├── hpa.yaml
│   │   ├── ingress.yaml
│   │   ├── linkerd.yaml
│   │   ├── redis
│   │   │   ├── config.yaml
│   │   │   ├── deployment.yaml
│   │   │   └── service.yaml
│   │   ├── service.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── servicemonitor.yaml
│   │   └── tests
│   │       ├── cache.yaml
│   │       ├── cypress-test.yaml
│   │       ├── fail.yaml
│   │       ├── script-test.yaml
│   │       ├── timeout.yaml
│   │       └── tls.yaml
│   ├── tests
│   │   ├── cypress
│   │   │   ├── cypress.json
│   │   │   └── podinfo-health.spec.js
│   │   └── scripts
│   │       └── script-tests.sh
│   ├── values-prod.yaml
│   └── values.yaml
├── kustomize
│   ├── helmrelease.yaml
│   ├── kustomization.yaml
│   └── values.yaml
```

Notice the `kustomize` directory - it essentially targets the two files in the directory

```
resources:
- helmrelease.yaml
- values.yaml
```

## Reconciliation
With the values overrides above in Big Bang for a package (pointed at git / OCI support would need to be evaluated here as well):

- Big Bang deploys the flux `gitrepository`, `namespace`, `imagepullsecret` and chart values `secret` for the package
- Big Bang deploys a flux `kustomization` resource that uses that `gitrepository`
- The path specified in the `kustomization` then creates the `helmrelease` and values `secret`
- The `helmrelease` uses the same `gitrepository` deployed by Big Bang - but targets the `chart/` path
- This `helmrelease` deploys the package application and has mapped big bang values passed from the umbrella - through the kustomization - to the package values secret.


## Extensibility
We would establish the global values to be passed down to any application in the `chart/templates/packages/kustomization.yaml` substitutes field. Packages would then use their kustomize directory to indicate which values they expect from the umbrella and what they map to internally. This would also mean that a given addon today would need to move other resources to either this `kustomize` directory or internally to the package. We can also allow for overriding these values as well as appending new values that would be needed dynamically downstream.

## Try it out

- Deploy flux and Big Bang umbrella
- Use the provided podinfo override values:
    - 
    ```
    packages:
        podinfo:
            enabled: true
            wrapper:
                enabled: false
            kustomize: true
            git:
                repo: https://repo1.dso.mil/big-bang/apps/sandbox/podinfo.git
                tag: null
                branch: "kustom_podinfo"
                path: kustomize
    ```
- Deploy another helm release of big bang with the above overrides
- it should deploy a `kustomization` in the podinfo namespace (should flux resources for these live here?)
- that will deploy a `helmrelease` resource which starts reconciliation of the chart