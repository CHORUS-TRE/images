# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        unzip \
        ca-certificates \
        curl \
        libpng-dev \
        libtiff-dev \
        libjpeg-dev \
        libfftw3-dev \
        libgsl-dev \
        libdcmtk-dev \
        libexpat1-dev \
        libx11-dev \
        libxt-dev \
        libglu1-mesa-dev \
        libxi-dev \
        libxmu-dev \
        libxmu-headers \
        libtbb-dev \
        libeigen3-dev && \
    curl -sSL -C - -O "https://github.com/ANTsX/ANTs/releases/download/v2.5.3/ants-2.5.3-ubuntu-24.04-X64-gcc.zip" && \
    unzip ants-2.5.3-ubuntu-24.04-X64-gcc.zip && \
    rm ants-2.5.3-ubuntu-24.04-X64-gcc.zip && \
    apt-get remove -y --purge \
        curl unzip && \
    apt-get autoremove -y --purge

ENV APP_CMD_PREFIX="export PATH=/apps/${APP_NAME}/ants-2.5.3/bin:${PATH}"
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/wezterm"
ENV PROCESS_NAME="/usr/bin/wezterm"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh -a terminal && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 
    
ENTRYPOINT ["/docker-entrypoint.sh"]
