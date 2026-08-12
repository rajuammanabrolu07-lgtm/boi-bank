# Kubernetes manifests (Phase 4)

Single cluster, three namespaces for environment isolation:
- dev / staging / prod  (RBAC + NetworkPolicy + ResourceQuota per ns)

Structure (Kustomize):
- base/      shared Deployment, Service, probes, HPA
- overlays/  per-env patches (replicas, image tag, resources, secrets)

Every Deployment: liveness = /actuator/health/liveness,
readiness = /actuator/health/readiness, non-root securityContext.
Coming in Phase 4.
