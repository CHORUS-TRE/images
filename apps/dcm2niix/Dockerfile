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
    apt-get install --no-install-recommends -qy \
    curl unzip ca-certificates && \
    curl -sSOL https://github.com/rordenlab/dcm2niix/releases/download/v${APP_VERSION}/dcm2niix_lnx.zip && \
    unzip -q dcm2niix_lnx.zip -d /usr/local/bin && \
    chmod 755 /usr/local/bin/dcm2niix && \
    rm dcm2niix_lnx.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/kitty/kitty.app/bin/kitty"
ENV PROCESS_NAME="kitty"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh -a terminal && \
    cp entrypoint/docker-entrypoint.sh / && \
    cp entrypoint/1-create-user.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
