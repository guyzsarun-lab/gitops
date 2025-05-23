# gitops
[![release](https://github.com/guyzsarun-lab/gitops/actions/workflows/release.yaml/badge.svg)](https://github.com/guyzsarun-lab/gitops/actions/workflows/release.yaml)

## Project Build Status

| __Project__ | Build Status | Description |
| :--- | :--- | :--- |
| __dashy__ | [![dashy](https://github.com/guyzsarun-lab/gitops/actions/workflows/dashy.yaml/badge.svg)](https://github.com/guyzsarun-lab/gitops/actions/workflows/dashy.yaml) | HomeLab Dashboard |
| __toolchain__ | [![toolchain](https://github.com/guyzsarun-lab/gitops/actions/workflows/toolchain.yaml/badge.svg)](https://github.com/guyzsarun-lab/gitops/actions/workflows/toolchain.yaml) | DevOps Toolchain |
| __cyberchef__ | [![cyberchef](https://github.com/guyzsarun-lab/gitops/actions/workflows/cyberchef.yaml/badge.svg)](https://github.com/guyzsarun-lab/gitops/actions/workflows/cyberchef.yaml) | Selfhosted [CyberChef](https://github.com/gchq/CyberChef/) |
| __homepage__ | [![homepage](https://github.com/guyzsarun-lab/gitops/actions/workflows/homepage.yaml/badge.svg)](https://github.com/guyzsarun-lab/gitops/actions/workflows/homepage.yaml) | HomeLab Dashboard #2 |
| __glance__ | | News Feed |

## Project Structure

This repository follows the GitOps workflow to manage Kubernetes deployments. All changes to the cluster are performed by updating this repository, and the changes are automatically applied using [ArgoCD](https://argo-cd.readthedocs.io/) 

```markdown
├── .github             # github action workflows
├── applicationset      # argocd applicationset generator
│   ├── base            # base kustomize template
│   └── ...     
|
└──  changedetection    # argocd managed application
```

## Deployment

To deploy an application, you can tag the repository follows the naming convention: `<application-name>-<version>`. This tag triggers the deployment process via GitHub Actions.

- Container image will be pushed to GitHub Container Registry.
- Github Action will update the version in the `kustomization.yaml` file.
- ArgoCD will sync the application with the new version.