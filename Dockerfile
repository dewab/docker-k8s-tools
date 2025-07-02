# ================================
# Builder Stage: Install Tools
# ================================
ARG TARGET_OS=${TARGET_OS:-linux}
ARG TARGET_ARCH=${TARGET_ARCH:-amd64}

FROM debian:bookworm-slim AS builder
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG TARGET_OS
ARG TARGET_ARCH
ARG IMAGE_VERSION

ARG YQ_VERSION
ARG HELM_VERSION
ARG YTT_VERSION
ARG KAPP_VERSION
ARG KCTRL_VERSION
ARG KBLD_VERSION
ARG IMGPKG_VERSION
ARG VENDIR_VERSION
ARG K9S_VERSION
ARG TANZU_CLI_VERSION
ARG VELERO_VERSION
ARG KUBECTL_VERSION
ARG KUBECTX_VERSION

LABEL org.opencontainers.image.title="k8s-cli-toolkit" \
      org.opencontainers.image.description="Multi-arch container with Kubernetes CLI tools" \
      org.opencontainers.image.source="https://github.com/dewab/docker-k8s-tools" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.authors="dwhicker@bifrost.cc"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      curl git ca-certificates tar jq binutils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Consolidated tool installation
RUN set -e && \
  # yq
  curl -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${TARGET_OS}_${TARGET_ARCH}" && chmod +x /usr/local/bin/yq && \
  # helm
  curl -fsSL -o helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-${TARGET_OS}-${TARGET_ARCH}.tar.gz" && \
    tar -xzf helm.tar.gz --strip-components=1 -C /usr/local/bin "${TARGET_OS}-${TARGET_ARCH}/helm" && rm helm.tar.gz && \
  # ytt
  curl -fsSL -o /usr/local/bin/ytt "https://github.com/carvel-dev/ytt/releases/download/v${YTT_VERSION}/ytt-${TARGET_OS}-${TARGET_ARCH}" && chmod +x /usr/local/bin/ytt && \
  # kapp
  curl -fsSL -o /usr/local/bin/kapp "https://github.com/carvel-dev/kapp/releases/download/v${KAPP_VERSION}/kapp-${TARGET_OS}-${TARGET_ARCH}" && chmod +x /usr/local/bin/kapp && \
  # kctrl
  curl -fsSL -o /usr/local/bin/kctrl "https://github.com/carvel-dev/kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-${TARGET_OS}-${TARGET_ARCH}" && chmod +x /usr/local/bin/kctrl && \
  # kbld
  curl -fsSL -o /usr/local/bin/kbld "https://github.com/carvel-dev/kbld/releases/download/v${KBLD_VERSION}/kbld-${TARGET_OS}-${TARGET_ARCH}" && chmod +x /usr/local/bin/kbld && \
  # imgpkg
  curl -fsSL -o /usr/local/bin/imgpkg "https://github.com/carvel-dev/imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-${TARGET_OS}-${TARGET_ARCH}" && chmod +x /usr/local/bin/imgpkg && \
  # vendir
  curl -fsSL -o /usr/local/bin/vendir "https://github.com/carvel-dev/vendir/releases/download/v${VENDIR_VERSION}/vendir-${TARGET_OS}-${TARGET_ARCH}" && chmod +x /usr/local/bin/vendir && \
  # k9s
  echo "K9S_VERSION=${K9S_VERSION}, TARGET_OS=${TARGET_OS}, TARGET_ARCH=${TARGET_ARCH}" && \
  K9S_OS=$(echo "$TARGET_OS" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') && \
  K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_${K9S_OS}_${TARGET_ARCH}.tar.gz" && \
  echo "⏬ Downloading: $K9S_URL" && \
  curl -fSL -o k9s.tar.gz "$K9S_URL" && \
  tar -xzf k9s.tar.gz && mv k9s /usr/local/bin/k9s && chmod +x /usr/local/bin/k9s && rm k9s.tar.gz && \
  # tanzu CLI
  TANZU_FILENAME="tanzu-cli-${TARGET_OS}-${TARGET_ARCH}.tar.gz" && \
  if [ "${TARGET_OS}" = "linux" ] && [ "${TARGET_ARCH}" = "arm64" ]; then \
    TANZU_FILENAME="tanzu-cli-${TARGET_OS}-${TARGET_ARCH}-unstable.tar.gz"; fi && \
  curl -fsSL -o tanzu-cli.tar.gz "https://github.com/vmware-tanzu/tanzu-cli/releases/download/v${TANZU_CLI_VERSION}/${TANZU_FILENAME}" && \
  mkdir tanzu-extract && \
  tar -xzf tanzu-cli.tar.gz -C tanzu-extract && \
  mv tanzu-extract/v${TANZU_CLI_VERSION}/tanzu-cli-* /usr/local/bin/tanzu && \
  chmod +x /usr/local/bin/tanzu && \
  rm -rf tanzu-cli.tar.gz tanzu-extract && \
  # velero
  curl -fsSL -o velero.tar.gz "https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-${TARGET_OS}-${TARGET_ARCH}.tar.gz" && \
  tar -xzf velero.tar.gz --strip-components=1 -C /usr/local/bin "velero-v${VELERO_VERSION}-${TARGET_OS}-${TARGET_ARCH}/velero" && chmod +x /usr/local/bin/velero && rm velero.tar.gz && \
  # kubectl
  curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGET_OS}/${TARGET_ARCH}/kubectl" && chmod +x /usr/local/bin/kubectl && \
  # kubectx
  KUBECTX_ARCH="${TARGET_ARCH}" && \
  if [ "$KUBECTX_ARCH" = "amd64" ]; then KUBECTX_ARCH="x86_64"; fi && \
  curl -fsSL -o kubectx.tar.gz "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx_v${KUBECTX_VERSION}_${TARGET_OS}_${KUBECTX_ARCH}.tar.gz" && \
  tar -xzf kubectx.tar.gz -C /usr/local/bin kubectx && chmod +x /usr/local/bin/kubectx && rm kubectx.tar.gz

RUN strip --strip-unneeded /usr/local/bin/*

# ================================
# Final Image
# ================================
FROM debian:bookworm-slim
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG TARGET_ARCH

RUN apt-get update && \
    apt-get install -y --no-install-recommends zsh git jq vim curl ca-certificates zsh-common zsh-autosuggestions exa locales fzf && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Create user with /k8s as home, ensure home ownership, copy tools from builder
RUN groupadd -r k8s && useradd -m -d /k8s -s /bin/zsh -g k8s k8suser && \
    chown -R k8suser:k8s /k8s

COPY --from=builder /usr/local/bin /usr/local/bin

# Copy all supporting files in one layer
COPY files/zshrc \
    files/banner.txt \
    files/entrypoint.sh \
    files/kubectl-vsphere \
    files/tkgs-login \
    files/tmc-get-kubeconfigs \
    /tmp/

# Append zshrc to system-wide /etc/zsh/zshrc, move other files, and handle kubectl-vsphere
RUN cat /tmp/zshrc >> /etc/zsh/zshrc \
    && mv /tmp/banner.txt /banner.txt \
    && mv /tmp/entrypoint.sh /entrypoint.sh \
    && mv /tmp/tkgs-login /usr/local/bin/tkgs-login \
    && chmod +x /usr/local/bin/tkgs-login \
    && mv /tmp/tmc-get-kubeconfigs /usr/local/bin/tmc-get-kubeconfigs \
    && chmod +x /usr/local/bin/tmc-get-kubeconfigs \
    && chmod +x /entrypoint.sh \
    && mkdir -p /work && chown k8suser:k8s /work \
    && if [ "$TARGET_ARCH" = "amd64" ]; then \
         mv /tmp/kubectl-vsphere /usr/local/bin/kubectl-vsphere \
         && chmod +x /usr/local/bin/kubectl-vsphere; \
       else \
         rm -f /tmp/kubectl-vsphere; \
       fi \
    && chown -R k8suser:k8s /k8s

# Create command completions at build time to speed up container startup
RUN mkdir -p /usr/local/share/zsh/site-functions && \
    kubectl completion zsh > /usr/local/share/zsh/site-functions/_kubectl && \
    helm completion zsh > /usr/local/share/zsh/site-functions/_helm && \
    ytt completion zsh > /usr/local/share/zsh/site-functions/_ytt 2>/dev/null || true && \
    imgpkg completion zsh | grep -v ^Succeeded > /usr/local/share/zsh/site-functions/_imgpkg 2>/dev/null || true && \
    kapp completion zsh | grep -v ^Succeeded > /usr/local/share/zsh/site-functions/_kapp 2>/dev/null || true && \
    kctrl completion zsh | grep -v ^Succeeded > /usr/local/share/zsh/site-functions/_kctrl 2>/dev/null || true && \
    vendir completion zsh | grep -v ^Succeeded > /usr/local/share/zsh/site-functions/_vendir 2>/dev/null || true && \
    k9s completion zsh > /usr/local/share/zsh/site-functions/_k9s 2>/dev/null || true && \
    tanzu completion zsh > /usr/local/share/zsh/site-functions/_tanzu 2>/dev/null || true && \
    velero completion zsh > /usr/local/share/zsh/site-functions/_velero 2>/dev/null || true && \
    yq completion zsh > /usr/local/share/zsh/site-functions/_yq 2>/dev/null || true && \
    kubectl-vsphere completion zsh > /usr/local/share/zsh/site-functions/_kubectl-vsphere 2>/dev/null || true

# Collect tool versions to display in the banner
RUN jq -n \
  --arg kubectl "$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion')" \
  --arg helm "$(helm version --short)" \
  --arg ytt "$(ytt version 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg kapp "$(kapp version 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg kctrl "$(kctrl version 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg kbld "$(kbld version 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg imgpkg "$(imgpkg version 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg vendir "$(vendir version 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg k9s "$(k9s version -s 2>/dev/null | grep -Eo '[0-9.]+' | head -n1)" \
  --arg tanzu "$(tanzu version | grep ^version | grep -Eo '[0-9.]+' | head -n1)" \
  --arg velero "$(velero version 2>/dev/null | grep -Eo 'v[0-9.]+' | head -n1)" \
  --arg yq "$(yq --version 2>/dev/null | grep -Eo '[0-9.]+$')" \
  --arg kubectx "$(kubectx -V 2>/dev/null | awk '{print $2}')" \
  '{kubectl: $kubectl, helm: $helm, ytt: $ytt, kapp: $kapp, kctrl: $kctrl, kbld: $kbld, imgpkg: $imgpkg, vendir: $vendir, k9s: $k9s, tanzu: $tanzu, velero: $velero, yq: $yq, kubectx: $kubectx}' \
  > /versions.json

ENV PATH="/usr/local/bin:$PATH"
ENV HOME=/k8s
WORKDIR /work

RUN chown -R k8suser:k8s /usr/local/share/ca-certificates /etc/ssl/certs

EXPOSE 80

USER k8suser

CMD ["/entrypoint.sh"]
