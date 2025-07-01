# 🧰 Kubernetes CLI Toolkit (Multi-Arch)

[![Build and Push to GHCR](https://github.com/dewab/docker-k8s-tools/actions/workflows/build.yaml/badge.svg)](https://github.com/dewab/docker-k8s-tools/actions/workflows/build.yaml)

This is intended to be an opinionated comprehensive tooling environment for deploying, adminsitering, and maintaining Tanzu (TKGS, Tanzu Mission Control) -based environments.  It designed to ease the tool deployment requirements for adminsitrators, especially those in Windows-based environments.  It provides an interactive shell (ZSH) that has command-line completions enabled for all commands.

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
  -v ${HOME}/.kube/config:/kubeconfig \
  -p 19191:80 \
  ghcr.io/dewab/docker-k8s-tools:latest
```

Volumes:

- **/k8s**: Persistent home directory for configs, history, and Tanzu plugins.
- **/ca**: (Optional) Mount a directory with `.crt` or `.pem` files to add custom CAs. These are copied to `/k8s/.ca` and trusted by the system.  This can be a one-time mount to populate your certificate authorities.
- **/work**: (Optional) Mount your manifests or working directory.  it's intended to be a bind-mount.
- **/kubeconfig**: (Optional) Mount a pre-existing kubeconfig file to have it copied into the container.  This can be a one-time mount to pre-populate your kubeconfig.

You can also map your existing `.kube` directory to `/k8s/.kube/` if you already have kubeconfigs.

Port 19191 is published and redirected to allow for callback redirects on hosts where port 80 requires root (Linux).  The callback URL is *NOT* rewritten (I'm working on this), so to post the return callback, you'd need to change the URL in the browser from 127.0.0.1 to 127.0.0.1:19191.  If running on Windows, you should be able to use `-p 80:80` instead and use the callback URL as written.

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
