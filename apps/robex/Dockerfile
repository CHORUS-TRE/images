# syntax=docker/dockerfile:1
#FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:22.04
FROM ubuntu:22.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    ca-certificates curl && \
    curl -sSL 'https://www.nitrc.org/frs/download.php/5994/ROBEXv12.linux64.tar.gz/?i_agree=1&download_now=1' -o robex-${APP_VERSION}.tar.gz && \
    tar -zxf robex-${APP_VERSION}.tar.gz --no-same-owner && \
    rm -f robex-${APP_VERSION}.tar.gz && \
    mv ROBEX robex && \
    chmod 755 robex/runROBEX.sh robex/ROBEX && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_CMD_PREFIX="export PATH=/apps/${APP_NAME}/robex:${PATH}"
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty"
ENV PROCESS_NAME="kitty"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh -a terminal && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
