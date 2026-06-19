# Kubernetes Templates

This directory contains reusable Kubernetes resource templates to reduce code duplication across the repository.

## Overview

The GitOps repository contains multiple applications with similar Kubernetes resources. These templates provide a starting point for new applications and document common patterns used across the repository.

## Templates

### VirtualService Templates

#### virtualservice-base.yaml
Base template for a simple VirtualService that routes traffic to a single service.

**Use case**: Simple applications exposed at a dedicated hostname (e.g., `app.proxmox.homelab`)

**Key customization points**:
- `spec.hosts`: The hostname(s) for your application
- `spec.http.route.destination.host`: The Kubernetes service name
- `spec.http.route.destination.port.number`: The service port

**Example VirtualService (copy and customize)**:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-vs
spec:
  gateways:
  - istio-system/default-gateway
  hosts:
  - myapp.proxmox.homelab
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: myapp-application.default.svc.cluster.local
        port:
          number: 3000
```

#### virtualservice-with-rewrite.yaml
Template for VirtualService with URI rewriting (for apps running under a path prefix).

**Use case**: Applications served under a path on a shared gateway (e.g., `gateway.proxmox.homelab/myapp`)

**Key customization points**:
- `spec.hosts`: The shared gateway hostname
- `spec.http.match.uri.prefix`: The URL path prefix (e.g., `/myapp`)
- `spec.http.route.destination.host`: The Kubernetes service name

**Example VirtualService (copy and customize)**:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp-vs
spec:
  gateways:
  - istio-system/default-gateway
  hosts:
  - gateway.proxmox.homelab
  http:
  - match:
    - uri:
        prefix: /myapp
    rewrite:
      uri: /
    route:
    - destination:
        host: myapp-application.default.svc.cluster.local
        port:
          number: 3000
```

### Volume Templates

#### nfs-volume-base.yaml
Base template for NFS-backed PersistentVolume and PersistentVolumeClaim.

**Use case**: Applications requiring persistent storage backed by NFS

**Key customization points**:
- `metadata.name`: Unique name for PV and PVC
- `spec.capacity.storage`: Storage size (e.g., `5Gi`, `10Gi`)
- `spec.storageClassName`: Unique storage class name
- `spec.nfs.path`: NFS export path

**Example Volume (copy and customize)**:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: myapp-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  storageClassName: myapp
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /home/devops/nfs_share/myapp
    server: nfs.proxmox.homelab
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-pvc
spec:
  storageClassName: myapp
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 5Gi
```

### Service Port Patch Template

Many applications use the same base service from `applicationset/base/service.yaml` but need different target ports.

**Example service patch**:
```yaml
# patches/service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: application
  name: application
spec:
  ports:
  - $patch: replace
  - port: 3000
    protocol: TCP
    targetPort: 8080  # Change to your app's port
```

### Deployment Resource Limits Patch Template

**Example deployment resource limits patch**:
```yaml
# patches/deployment-memory.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: application
spec:
  template:
    spec:
      containers:
      - name: application
        resources:
          limits:
            memory: 256Mi  # Adjust as needed
            cpu: 100m      # Adjust as needed
```

## Common Patterns

### Pattern 1: Simple Application with Dedicated Hostname

```
myapp/
├── kustomization.yaml
└── vs.yaml
```

**kustomization.yaml**:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
- vs.yaml
namePrefix: myapp-
images:
- name: ghcr.io/guyzsarun-lab/base
  newName: ghcr.io/guyzsarun-lab/myapp
  newTag: v1.0.0
commonLabels:
  app: myapp
```

### Pattern 2: Application with Custom Port

```
myapp/
├── kustomization.yaml
├── patches/
│   ├── service.yaml
│   └── deployment.yaml
└── vs.yaml
```

### Pattern 3: Application with Persistent Storage

```
myapp/
├── kustomization.yaml
├── volume.yaml
├── patches/
│   └── deployment-volume.yaml
└── vs.yaml
```

## Benefits

- **Reduced Duplication**: Common patterns are documented and reusable
- **Consistency**: All applications follow similar structures
- **Easier Onboarding**: New applications can copy existing patterns
- **Self-Documenting**: Templates serve as live documentation

## Creating a New Application

1. Copy one of the existing applications that most closely matches your needs
2. Update the application name throughout
3. Customize ports, hostnames, and resource limits
4. Add any application-specific configuration (secrets, configmaps, etc.)
5. Test with `kubectl kustomize applicationset/myapp` before committing
6. Add a GitHub workflow if building a custom Docker image

## Validation

Before committing changes, validate your Kustomize configuration:

```bash
# Validate kustomization
kubectl kustomize applicationset/myapp

# Check for common issues
kubectl kustomize applicationset/myapp | kubectl apply --dry-run=client -f -
```
