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
    apt-get install --no-install-recommends -y \ 
    ca-certificates curl unzip libgomp1 libgtk-3-0 libglib2.0-0 \
    libglib2.0-0 dbus-x11 at-spi2-core && \
    curl -sSL -o HiBoP.${APP_VERSION}.linux64.zip "https://github.com/hbp-HiBoP/HiBoP/releases/download/${APP_VERSION}/HiBoP.${APP_VERSION}.linux64.zip" && \
    unzip -q -d . HiBoP.${APP_VERSION}.linux64.zip && \
    chmod 755 ./HiBoP.${APP_VERSION}.linux64/HiBoP.x86_64 && \
    rm HiBoP.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/HiBoP.${APP_VERSION}.linux64/HiBoP.x86_64"
ENV PROCESS_NAME="/apps/${APP_NAME}/HiBoP.${APP_VERSION}.linux64/HiBoP.x86_64"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /
    
ENTRYPOINT ["/docker-entrypoint.sh"]

