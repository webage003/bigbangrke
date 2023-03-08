
This Style Guide explains general conventions.

## Product Names

Product names must be lower case letters and numbers. Words _may_ be separated
with dashes (-):

Examples:

```
drupal
nginx-lego
aws-cluster-autoscaler
```

Neither uppercase letters nor underscores can be used in product names. Dots
should not be used in product names.

#### Notable exceptions:
     
When a product name is 2 words and additional words are < 4 characters it can be considered part of the single name. Examples include: fluentbit (technically Fluent Bit) and argocd (technically Argo CD).

## Version Numbers

Wherever possible, Helm uses [SemVer 2](https://semver.org) to represent version
numbers. (Note that Docker image tags do not necessarily follow SemVer, and are
thus considered an unfortunate exception to the rule.)

When SemVer versions are stored in Kubernetes labels, we conventionally alter
the `+` character to an `_` character, as labels do not allow the `+` sign as a
value.

## Formatting YAML

YAML files should be indented using _two spaces_ (and never tabs).
