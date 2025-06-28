# ================================
# Builder Stage: Install Tools
# ================================
ARG TARGET_OS=linux
ARG TARGET_ARCH=arm64

FROM alpine:3.22 AS builder
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

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

LABEL org.opencontainers.image.title="k8s-cli-toolkit" \
      org.opencontainers.image.description="Multi-arch container with Kubernetes CLI tools" \
      org.opencontainers.image.source="https://github.com/dewab/docker-k8s-tools" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.authors="dwhicker@bifrost.cc"

RUN apk add --no-cache curl git tar

# Install directory
RUN mkdir -p /k8s/bin && echo 'export PATH="/k8s/bin:$PATH"' >> /etc/profile.d/k8s-path.sh

WORKDIR /tmp

# Helper function to download and install tools
# Each tool uses the following pattern:
# 1. Download
# 2. (Optional) SHA256 check placeholder
# 3. Move to /k8s/bin and make executable

# -- yq
RUN curl -fsSL -o /k8s/bin/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${TARGET_OS}_${TARGET_ARCH}" \
 && chmod +x /k8s/bin/yq

# -- helm
RUN curl -fsSL -o helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-${TARGET_OS}-${TARGET_ARCH}.tar.gz" \
 && tar -xzf helm.tar.gz --strip-components=1 -C /k8s/bin "${TARGET_OS}-${TARGET_ARCH}/helm" \
 && rm helm.tar.gz

# -- ytt
RUN curl -fsSL -o /k8s/bin/ytt "https://github.com/carvel-dev/ytt/releases/download/v${YTT_VERSION}/ytt-${TARGET_OS}-${TARGET_ARCH}" \
 && chmod +x /k8s/bin/ytt

# -- kapp
RUN curl -fsSL -o /k8s/bin/kapp "https://github.com/carvel-dev/kapp/releases/download/v${KAPP_VERSION}/kapp-${TARGET_OS}-${TARGET_ARCH}" \
 && chmod +x /k8s/bin/kapp

# -- kctrl
RUN curl -fsSL -o /k8s/bin/kctrl "https://github.com/carvel-dev/kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-${TARGET_OS}-${TARGET_ARCH}" \
 && chmod +x /k8s/bin/kctrl

# -- kbld
RUN curl -fsSL -o /k8s/bin/kbld "https://github.com/carvel-dev/kbld/releases/download/v${KBLD_VERSION}/kbld-${TARGET_OS}-${TARGET_ARCH}" \
 && chmod +x /k8s/bin/kbld

# -- imgpkg
RUN curl -fsSL -o /k8s/bin/imgpkg "https://github.com/carvel-dev/imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-${TARGET_OS}-${TARGET_ARCH}" \
 && chmod +x /k8s/bin/imgpkg

# -- vendir
RUN curl -fsSL -o /k8s/bin/vendir "https://github.com/carvel-dev/vendir/releases/download/v${VENDIR_VERSION}/vendir-${TARGET_OS}-${TARGET_ARCH}" \
 && chmod +x /k8s/bin/vendir

# Declare ARG if not already in scope
ARG K9S_VERSION

# -- k9s
RUN echo "K9S_VERSION=${K9S_VERSION}, TARGET_OS=${TARGET_OS}, TARGET_ARCH=${TARGET_ARCH}" && \
    K9S_OS=$(echo "$TARGET_OS" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') && \
    K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_${K9S_OS}_${TARGET_ARCH}.tar.gz" && \
    echo "⏬ Downloading: $K9S_URL" && \
    curl -fSL -o k9s.tar.gz "$K9S_URL" && \
    tar -xzf k9s.tar.gz && mv k9s /k8s/bin/k9s && chmod +x /k8s/bin/k9s && rm k9s.tar.gz

# -- tanzu CLI
RUN TANZU_FILENAME="tanzu-cli-${TARGET_OS}-${TARGET_ARCH}.tar.gz" \
 && if [ "${TARGET_OS}" = "linux" ] && [ "${TARGET_ARCH}" = "arm64" ]; then \
      TANZU_FILENAME="tanzu-cli-${TARGET_OS}-${TARGET_ARCH}-unstable.tar.gz"; fi \
 && curl -fsSL -o tanzu-cli.tar.gz "https://github.com/vmware-tanzu/tanzu-cli/releases/download/v${TANZU_CLI_VERSION}/${TANZU_FILENAME}" \
 && mkdir tanzu-extract \
 && tar -xzf tanzu-cli.tar.gz -C tanzu-extract \
 && mv tanzu-extract/v${TANZU_CLI_VERSION}/tanzu-cli-* /k8s/bin/tanzu \
 && chmod +x /k8s/bin/tanzu \
 && rm -rf tanzu-cli.tar.gz tanzu-extract

# -- velero
RUN curl -fsSL -o velero.tar.gz "https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-${TARGET_OS}-${TARGET_ARCH}.tar.gz" \
 && tar -xzf velero.tar.gz --strip-components=1 -C /k8s/bin "velero-v${VELERO_VERSION}-${TARGET_OS}-${TARGET_ARCH}/velero" \
 && chmod +x /k8s/bin/velero \
 && rm velero.tar.gz

# -- kubectl
RUN curl -fsSL -o /k8s/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGET_OS}/${TARGET_ARCH}/kubectl" \
 && chmod +x /k8s/bin/kubectl

# ================================
# Final Image
# ================================
FROM alpine:3.22

RUN apk add --no-cache socat zsh zsh-vcs jq git ca-certificates

# Create user with /k8s as home
RUN addgroup -S k8s && adduser -S -G k8s -h /k8s k8suser

# Ensure home directory has correct ownership
RUN chown -R k8suser:k8s /k8s

# Copy tools from builder
COPY --from=builder /k8s /k8s

# Copy supporting files
COPY files/zshrc /k8s/.zshrc
COPY files/banner.txt /banner.txt
COPY files/entrypoint.sh /entrypoint.sh

# Ensure correct permissions before switching user
RUN chmod +x /entrypoint.sh && \
    chown -R k8suser:k8s /k8s && \
    mkdir /work && chown k8suser:k8s /work

# Set up environment
ENV PATH="/k8s/bin:$PATH"
ENV HOME=/k8s
WORKDIR /work

USER k8suser

# Expose port and run entrypoint
EXPOSE 19191
CMD ["/entrypoint.sh"]
