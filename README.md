# 🧰 Kubernetes CLI Toolkit (Multi-Arch)

[![Build and Push to GHCR](https://github.com/dewab/docker-k8s-tools/actions/workflows/build.yaml/badge.svg)](https://github.com/dewab/docker-k8s-tools/actions/workflows/build.yaml)

A compact, multi-architecture Docker image bundling essential Kubernetes tooling for day-to-day cluster and deployment operations.

Supports both `amd64` and `arm64` platforms. Ideal for CI pipelines, developer shells, or automation containers.

---

## 📦 Included Tools

| Tool       | Description                              |
|------------|------------------------------------------|
| `yq`       | YAML processor                           |
| `helm`     | Kubernetes package manager               |
| `ytt`      | YAML templating tool (Carvel)            |
| `kapp`     | App deployment tool (Carvel)             |
| `kctrl`    | App CR control CLI (Carvel)              |
| `kbld`     | Build and image reference tool (Carvel)  |
| `imgpkg`   | OCI image packaging tool (Carvel)        |
| `vendir`   | Vendor directory manager (Carvel)        |
| `k9s`      | Terminal UI for managing K8s clusters    |
| `tanzu`    | VMware Tanzu CLI                         |
| `velero`   | Backup and restore CLI                   |
| `kubectl`  | Kubernetes CLI                           |

> **Note:** The `kubectl-vsphere` plugin is included only on the `amd64` platform. There is currently no official Linux `arm64` build available.

---

## 🚀 Quick Start

```bash
docker run --rm -it \
  -v <homevolume>:/k8s \
  -v <cavolume>:/ca \
  -v <manifestdir>:/work \
  ghcr.io/dewab/docker-k8s-tools:latest
```

- **/k8s**: Persistent home directory for configs, history, and Tanzu plugins.
- **/ca**: (Optional) Mount a directory with `.crt` or `.pem` files to add custom CAs. These are copied to `/k8s/.ca` and trusted by the system.
- **/work**: (Optional) Mount your manifests or working directory.

You can also map your existing `.kube` directory to `/k8s/.kube/` if you already have kubeconfigs.

---

## 🛠️ Features & Behavior

- On first startup with an empty home directory, Tanzu CLI is initialized and essential plugins are installed (requires internet access; may take a few minutes).
- The status bar with kube contexts appears once a kubeconfig exists.
- Velero version is shown only if a kubeconfig is present.
- All included tools have tab completion enabled.

---

## 📝 Notes

- If you mount a `/ca` volume, all `.crt` and `.pem` files are persisted in `/k8s/.ca` and added to the trusted certificate store. This only needs to be done when CAs are updated.
- For multi-arch builds, use Docker Buildx or the provided build scripts.
- For best experience, use a persistent `/k8s` volume to retain history, plugins, and configuration between runs.

---

Enjoy your streamlined Kubernetes CLI environment!
