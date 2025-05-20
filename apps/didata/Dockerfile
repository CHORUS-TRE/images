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
        apt-transport-https \
        ca-certificates \
        wget \
        gpg \
        binutils \
        libglib2.0-0 \
        libnss3 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        libdrm2 \
        libgtk-3-0 \
        libgbm1 \
        libasound2t64 \
        libx11-6 \
        libxcomposite1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxrandr2 \
        libxrender1 \
        libxtst6 \
        libatomic1 \
        xvfb && \
    # Download and install NW.js
    wget https://dl.nwjs.io/v${APP_VERSION}/nwjs-v${APP_VERSION}-linux-x64.tar.gz && \
    tar -xzf nwjs-v${APP_VERSION}-linux-x64.tar.gz && \
    mv nwjs-v${APP_VERSION}-linux-x64 /opt/nwjs && \
    ln -s /opt/nwjs/nw /usr/local/bin/nw && \
    rm nwjs-v${APP_VERSION}-linux-x64.tar.gz && \
    apt-get remove -y --purge wget gpg && \
    apt-get autoremove -y --purge

COPY src/* /apps/${APP_NAME}/
RUN chown -R 1001:1001 /apps/${APP_NAME}

ENV APP_SPECIAL="no"
ENV APP_CMD="nw /apps/${APP_NAME}"
ENV PROCESS_NAME="nw"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 
    
ENTRYPOINT ["/docker-entrypoint.sh"]