# Contributing to GitOps

Thank you for your interest in contributing to this GitOps repository!

## Overview

This repository uses GitOps practices to manage Kubernetes deployments via ArgoCD. All changes to the cluster are made by updating this repository.

## Repository Structure

```
├── .github/workflows/     # GitHub Actions CI/CD pipelines
├── applicationset/        # Application configurations
│   ├── base/             # Base Kustomize templates
│   └── <app>/            # Individual application configs
├── k8s-templates/        # Reusable Kubernetes resource templates
├── cluster-bootstrap/    # Cluster infrastructure components
└── changedetection/      # Standalone application
```

## Adding a New Application

### Quick Start

1. **Choose a template approach**:
   - Copy an existing similar application from `applicationset/`
   - Or start from scratch using templates in `k8s-templates/`

2. **Create your application directory**:
   ```bash
   mkdir -p applicationset/myapp
   ```

3. **Create required files**:
   - `kustomization.yaml` - Kustomize configuration
   - `vs.yaml` - VirtualService for Istio routing
   - Optional: `volume.yaml` - Persistent storage
   - Optional: `patches/` - Customizations to base resources

4. **Reference the base template**:
   ```yaml
   # applicationset/myapp/kustomization.yaml
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

5. **Test locally**:
   ```bash
   kubectl kustomize applicationset/myapp
   ```

6. **Create a GitHub workflow** (if building custom images):
   ```bash
   cp .github/workflows/cyberchef.yaml .github/workflows/myapp.yaml
   # Edit the file to update name and paths
   ```

7. **Commit and push**:
   ```bash
   git add applicationset/myapp
   git commit -m "Add myapp application"
   git push
   ```

### Detailed Guides

- [Kubernetes Templates Guide](k8s-templates/README.md) - Common patterns and templates
- [Workflow Guide](.github/workflows/README.md) - CI/CD pipeline patterns

## Common Patterns

### Pattern 1: Simple Web Application

For applications with:
- Single container
- Exposed via Istio VirtualService
- No persistent storage

**Example**: `cyberchef`, `toolchain`

### Pattern 2: Application with Configuration

For applications with:
- ConfigMaps for configuration files
- Volume mounts for config
- Patches to inject config

**Example**: `dashy`, `glance`

### Pattern 3: Application with Persistent Storage

For applications with:
- NFS-backed PersistentVolume
- Volume mounts in deployment
- Data persistence requirements

**Example**: `linkwarden`, `paperless`, `calibre`

### Pattern 4: Multi-Container Application

For applications with:
- Sidecar containers
- Multiple services
- Complex networking

**Example**: `linkwarden` (with meilisearch sidecar)

## Kustomize Best Practices

### Use Strategic Merge Patches

For modifying specific fields:
```yaml
# patches/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: application
spec:
  ports:
  - $patch: replace
  - port: 3000
    targetPort: 8080
```

### Use namePrefix for Resource Naming

Instead of hardcoding names, use `namePrefix`:
```yaml
namePrefix: myapp-
# Results in: myapp-application, myapp-vs, etc.
```

### Use commonLabels for Consistent Labeling

```yaml
commonLabels:
  app: myapp
```

## Validation

Before committing, always validate:

```bash
# Validate Kustomize output
kubectl kustomize applicationset/myapp

# Dry-run to catch issues
kubectl kustomize applicationset/myapp | kubectl apply --dry-run=client -f -

# Check YAML syntax
kubectl kustomize applicationset/myapp | kubectl apply --dry-run=server -f -
```

## Deployment Process

### Development/Testing (Push to Main)

1. Make changes to application configuration
2. Commit and push to `main` branch
3. ArgoCD automatically syncs changes to the cluster

### Production Release (Tagged Release)

1. Build and test your application
2. Create a Git tag: `git tag myapp-v1.0.0`
3. Push tag: `git push --tags`
4. GitHub Actions builds and pushes Docker image
5. Workflow updates `kustomization.yaml` with new version
6. ArgoCD syncs the new version

## Troubleshooting

### Kustomize Errors

```bash
# View detailed error output
kubectl kustomize applicationset/myapp

# Check for YAML syntax errors
yamllint applicationset/myapp/*.yaml
```

### ArgoCD Sync Issues

1. Check ArgoCD UI for sync status
2. Review ArgoCD application logs
3. Verify Git repository is accessible
4. Check resource quotas and RBAC permissions

### Docker Build Failures

1. Review GitHub Actions workflow logs
2. Verify Dockerfile syntax
3. Check base image availability
4. Ensure required build arguments are provided

## Code Review Guidelines

When reviewing PRs:

- [ ] Kustomize configuration is valid
- [ ] Resources follow naming conventions
- [ ] Labels are consistent
- [ ] VirtualService routes are correct
- [ ] Resource limits are appropriate
- [ ] Secrets are not committed to Git
- [ ] Documentation is updated if needed

## Resources

- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Istio VirtualService](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## Getting Help

- Review existing applications for examples
- Check [k8s-templates/README.md](k8s-templates/README.md) for common patterns
- Open an issue for questions or problems
- Consult the team before making infrastructure changes

## License

This project follows the same license as specified in [LICENSE](LICENSE).
