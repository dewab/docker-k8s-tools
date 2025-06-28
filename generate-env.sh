#!/bin/bash
# generate-env.sh

set -e

print_env() {
  local var="$1"
  local val="$2"
  if [[ -n "$val" ]]; then
    echo "ENV ${var}=${val}"
  else
    echo "# ENV ${var}= (not found)"
  fi
}

get_latest_github_release() {
  local repo="$1"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/' || true
}

# Fetch versions
YQ_VERSION=$(get_latest_github_release "mikefarah/yq")
HELM_VERSION=$(get_latest_github_release "helm/helm")
YTT_VERSION=$(get_latest_github_release "carvel-dev/ytt")
KAPP_VERSION=$(get_latest_github_release "carvel-dev/kapp")
KCTRL_VERSION=$(get_latest_github_release "carvel-dev/kapp-controller")
KBLD_VERSION=$(get_latest_github_release "carvel-dev/kbld")
IMGPKG_VERSION=$(get_latest_github_release "carvel-dev/imgpkg")
VENDIR_VERSION=$(get_latest_github_release "carvel-dev/vendir")
K9S_VERSION=$(get_latest_github_release "derailed/k9s")
TANZU_CLI_VERSION=$(get_latest_github_release "vmware-tanzu/tanzu-cli")
VELERO_VERSION=$(get_latest_github_release "vmware-tanzu/velero")
KUBECTL_VERSION=$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt | sed 's/^v//')

# Print as Docker ENV
print_env YQ_VERSION "$YQ_VERSION"
print_env HELM_VERSION "$HELM_VERSION"
print_env YTT_VERSION "$YTT_VERSION"
print_env KAPP_VERSION "$KAPP_VERSION"
print_env KCTRL_VERSION "$KCTRL_VERSION"
print_env KBLD_VERSION "$KBLD_VERSION"
print_env IMGPKG_VERSION "$IMGPKG_VERSION"
print_env VENDIR_VERSION "$VENDIR_VERSION"
print_env K9S_VERSION "$K9S_VERSION"
print_env TANZU_CLI_VERSION "$TANZU_CLI_VERSION"
print_env VELERO_VERSION "$VELERO_VERSION"
print_env KUBECTL_VERSION "$KUBECTL_VERSION"
