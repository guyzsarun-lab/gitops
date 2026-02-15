# GitHub Workflows

This directory contains GitHub Actions workflows for building and deploying applications.

## Workflow Types

### Individual Application Workflows

Files like `dashy.yaml`, `homepage.yaml`, `cyberchef.yaml`, and `toolchain.yaml` are minimal wrapper workflows that trigger on changes to specific application directories.

**Structure**:
```yaml
name: <app-name>

on:
  workflow_dispatch:
  push:
    branches:
      - main
    paths:
      - applicationset/<app-name>/**

jobs:
  docker-build:
    uses: ./.github/workflows/reusable-docker-build.yaml
    with:
      path: applicationset/<app-name>
```

### Reusable Workflows

#### reusable-docker-build.yaml

A reusable workflow that handles Docker image building and pushing. Used by all application workflows.

**Inputs**:
- `tag-name`: Docker image tag name (default: 'docker-build')
- `path`: Path to the application directory (required)
- `push`: Whether to push the image to registry (default: false)
- `version`: Image version tag (default: 'latest')

### Release Workflow

#### release.yaml

Triggered by Git tags following the pattern `<app-name>-<version>`. This workflow:
1. Parses the application name and version from the tag
2. Builds and pushes the Docker image
3. Updates the version in the application's `kustomization.yaml`
4. Commits the version update back to the repository

## Creating a New Application Workflow

To add a workflow for a new application:

1. **Copy an existing workflow** (e.g., `cyberchef.yaml`)
2. **Update the name** to match your application
3. **Update the paths** to trigger on your application directory
4. **Customize the path parameter** in the workflow call

**Example for a new app called "myapp"**:

```yaml
name: myapp

on:
  workflow_dispatch:
  push:
    branches:
      - main
    paths:
      - applicationset/myapp/**

jobs:
  docker-build:
    uses: ./.github/workflows/reusable-docker-build.yaml
    with:
      path: applicationset/myapp
```

## Why Individual Workflows?

While these workflows appear duplicated, they serve distinct purposes:

1. **Isolated Triggers**: Each workflow only runs when its specific application changes
2. **Clear Build Status**: Individual workflow badges in README.md show per-application status
3. **Flexible Configuration**: Each application can customize its workflow parameters if needed
4. **GitHub Actions Limitations**: GitHub Actions doesn't support dynamic workflow generation

The common build logic is extracted into `reusable-docker-build.yaml` to avoid true code duplication.

## Deployment Process

### Continuous Deployment (Push to Main)

1. Push changes to `applicationset/<app-name>/`
2. The application's workflow triggers
3. Docker image is built (but not pushed)
4. ArgoCD syncs the changes from the repository

### Release Deployment (Tagged)

1. Create a tag: `git tag <app-name>-v1.0.0 && git push --tags`
2. The `release.yaml` workflow triggers
3. Docker image is built and pushed to GitHub Container Registry
4. `kustomization.yaml` is updated with the new version
5. ArgoCD syncs the changes and deploys the new version

## Best Practices

- Keep individual workflows minimal (just trigger configuration)
- Put common logic in reusable workflows
- Use semantic versioning for release tags: `<app>-v<major>.<minor>.<patch>`
- Test kustomization locally before pushing: `kubectl kustomize applicationset/<app>`
