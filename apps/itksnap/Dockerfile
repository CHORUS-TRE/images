# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG APP_VERSION_FULL

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive

# Downloading from SourceForge performs a redirect, hence caching is hard.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        libfontconfig1 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxkbcommon-x11-0 \
        libxkbcommon0 && \
    pushd /var/cache/curl && \
    curl -sSL -o itksnap-${APP_VERSION_FULL}.tgz https://sourceforge.net/projects/itk-snap/files/itk-snap/${APP_VERSION}/itksnap-${APP_VERSION_FULL}-Linux-gcc64.tar.gz/download && \
    tar -xvzf itksnap-${APP_VERSION_FULL}.tgz && \
    mv itksnap-${APP_VERSION_FULL}-Linux-gcc64/* /apps/${APP_NAME} && \
    rmdir itksnap-${APP_VERSION_FULL}-Linux-gcc64 && \
    popd && \
    apt-get remove -y --purge \
        curl && \
    apt-get autoremove -y --purge

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    cp entrypoint/docker-entrypoint.sh / && \
    cp entrypoint/1-create-user.sh /docker-entrypoint.d

ENV PATH="${PATH}:/apps/${APP_NAME}/bin"
ENV APP_CMD="itksnap"
ENV APP_CMD_PREFIX="export PATH=${PATH}"

ENTRYPOINT ["/docker-entrypoint.sh"]
