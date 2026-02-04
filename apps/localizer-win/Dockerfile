# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive

# Download application binary
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install -qy ca-certificates curl unzip && \
    curl -sSOL https://github.com/CRNL-Eduwell/Localizer/releases/download/V${APP_VERSION}/Localizer.${APP_VERSION}.win64.zip && \
    mkdir ./install && \
    unzip -q -d ./install Localizer.${APP_VERSION}.win64.zip && \
    chmod -R 757 ./install && \
    rm Localizer.${APP_VERSION}.win64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/local/bin/wine-wrapper.sh /apps/${APP_NAME}/install/Localizer.${APP_VERSION}.win64/Localizer.exe"
ENV PROCESS_NAME="Localizer.exe"
ENV APP_DATA_DIR_ARRAY=".wine"
ENV DATA_DIR_ARRAY=""
ENV WINEDEBUG="-all"
ENV WINEARCH="win64"

# Install Wine environment + Chorus utilities
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/wine/install-wine.sh && \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
