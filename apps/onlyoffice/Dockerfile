# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy ca-certificates curl \
      libgtk-3-0t64 libxkbcommon-x11-0 libnss3 libasound2t64 \
      gsettings-desktop-schemas && \
    curl -ssOL https://github.com/ONLYOFFICE/appimage-desktopeditors/releases/download/v${APP_VERSION}/DesktopEditors-x86_64.AppImage && \
    chmod +x DesktopEditors-x86_64.AppImage && \
    ./DesktopEditors-x86_64.AppImage --appimage-extract && \
    rm -f DesktopEditors-x86_64.AppImage && \
    rm -f squashfs-root/usr/bin/libselinux.so.1 && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/squashfs-root/AppRun --system-title-bar"
ENV PROCESS_NAME="./DesktopEditors"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /
    
ENTRYPOINT ["/docker-entrypoint.sh"]
