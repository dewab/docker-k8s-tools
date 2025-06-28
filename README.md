# 🧰 Kubernetes CLI Toolkit (Multi-Arch)

A compact, multi-architecture Docker image bundling essential Kubernetes tooling for day-to-day cluster and deployment operations.

Built for both `amd64` and `arm64` platforms and ready for use in CI pipelines, developer shells, or automation containers.

---

## 📦 Included Tools

| Tool       | Description                              | Version (example) |
|------------|------------------------------------------|-------------------|
| `yq`       | YAML processor                           | v4.45.4           |
| `helm`     | Kubernetes package manager               | v3.18.3           |
| `ytt`      | YAML templating tool (Carvel)            | v0.52.0           |
| `kapp`     | App deployment tool (Carvel)             | v0.64.2           |
| `kctrl`    | App CR control CLI (Carvel)              | v0.58.0           |
| `kbld`     | Build and image reference tool (Carvel)  | v0.46.0           |
| `imgpkg`   | OCI image packaging tool (Carvel)        | v0.46.1           |
| `vendir`   | Vendor directory manager (Carvel)        | v0.44.0           |
| `k9s`      | Terminal UI for managing K8s clusters    | v0.50.6           |
| `tanzu`    | VMware Tanzu CLI                         | v1.1.x            |
| `velero`   | Backup and restore CLI                   | v1.16.1           |
| `kubectl`  | Kubernetes CLI                           | v1.31.0           |

> Versions are injected via build args and can be customized easily.

---

## 🏗️ How to Build

You can build for multiple platforms using Docker Buildx:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg YQ_VERSION=4.45.4 \
  --build-arg HELM_VERSION=3.18.3 \
  --build-arg YTT_VERSION=0.52.0 \
  --build-arg KAPP_VERSION=0.64.2 \
  --build-arg KCTRL_VERSION=0.58.0 \
  --build-arg KBLD_VERSION=0.46.0 \
  --build-arg IMGPKG_VERSION=0.46.1 \
  --build-arg VENDIR_VERSION=0.44.0 \
  --build-arg K9S_VERSION=0.50.6 \
  --build-arg TANZU_CLI_VERSION=1.1.5 \
  --build-arg VELERO_VERSION=1.16.1 \
  --build-arg KUBECTL_VERSION=1.31.0 \
  -t yourrepo/k8s-cli-toolkit:latest \
  --push .
```
