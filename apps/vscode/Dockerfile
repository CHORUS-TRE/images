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
        apt-transport-https ca-certificates \
        curl gpg binutils \
        python3 python3-venv python3-pip \
        build-essential libssl-dev libffi-dev python3-dev && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update -qy && \
    version=$(apt-cache madison code | grep -o "${APP_VERSION}-[0-9]*") && \
    apt-get install --no-install-recommends -y code=${version} && \
    apt-get remove -y --purge curl gpg && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/share/code/code --no-sandbox"
ENV PROCESS_NAME="/usr/share/code/code"
ENV APP_DATA_DIR_ARRAY=".config/Code .vscode"
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
