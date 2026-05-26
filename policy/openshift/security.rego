package main

deny contains msg if {
  input.kind == "Route"
  not input.spec.tls.termination
  msg := "Route must specify tls.termination (edge, passthrough, or reencrypt)"
}

deny contains msg if {
  input.kind == "Route"
  input.spec.tls.termination
  not input.spec.tls.termination == "edge"
  not input.spec.tls.termination == "passthrough"
  not input.spec.tls.termination == "reencrypt"
  msg := sprintf("Route tls.termination must be edge, passthrough, or reencrypt (got %v)", [input.spec.tls.termination])
}

deny contains msg if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.runAsUser
  msg := sprintf("Container %v must not set runAsUser — SCC assigns UID automatically", [container.name])
}

deny contains msg if {
  input.kind == "Deployment"
  input.spec.template.spec.securityContext
  msg := "Pod must not set pod-level securityContext — SCC enforces security policy"
}

deny contains msg if {
  input.kind == "Ingress"
  msg := "Ingress resources are not allowed in OpenShift manifests — use Route instead"
}
