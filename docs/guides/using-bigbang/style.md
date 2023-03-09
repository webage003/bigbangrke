This Style Guide explains general conventions.

## Package Names

Package names must be lowercase letters and numbers. Words _may_ be separated
with dashes (-):


Neither uppercase letters nor underscores can be used in package names. Dots
should not be used in package names.

Package names should be consistent between the git repository, namespace, resource prefixes and labels.

Package names from yaml can be translated to Kubernetes resource names using Helm's kebab-case function. This replaces capital letters with a - and the lowercase version of the letter.

#### Notable exceptions:
     
When a package name is 2 words and additional words are < 4 characters it can be considered part of the single name. Examples include: fluentbit (technically Fluent Bit) and argocd (technically Argo CD).

## Structure Standardization

The following items for each package should have the same name:
* Folder: `chart/templates/<package>`
* Top level key: `chart/templates/values.yaml`
* Namespace: `chart/templates/<package>/namespace.yaml` or `chart/templates/<package>/helmrelease.yaml`
  * unless targeting another package's namespace.
* Repo name: `https://repo1.dso.mil/bigbang/packages/<package>/`

## Version Numbers

### WIP Lots of discourse on this topic suggest updating this section when finalized
Wherever possible, Helm uses [SemVer 2](https://semver.org) to represent version
numbers. (Note that Docker image tags do not necessarily follow SemVer, and are
thus considered an unfortunate exception to the rule.)

When SemVer versions are stored in Kubernetes labels, we conventionally alter
the `+` character to an `_` character, as labels do not allow the `+` sign as a
value.

## Formatting YAML

* YAML files should be indented using _two spaces_ (and never tabs).
* Keys are camelCase and alphanumeric. No special characters
* All Kubernetes resource names, repository names, and namespaces are lowercase, alphanumeric or -, and kebab-case.
