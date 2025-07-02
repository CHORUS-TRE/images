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
    apt-get install --no-install-recommends -qy ca-certificates curl gnupg \
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://collaboraoffice.com/downloads/gpg/collaboraonline-snapshot-keyring.gpg \
        -o /usr/share/keyrings/collaboraonline-snapshot-keyring.gpg && \
    echo -e "Types: deb\nURIs: https://www.collaboraoffice.com/downloads/Collabora-Office-24-Snapshot/Linux/apt\nSuites: ./\nSigned-By: /usr/share/keyrings/collaboraonline-snapshot-keyring.gpg" \
        > /etc/apt/sources.list.d/collaboraoffice.sources && \
    apt-get update && \
    apt-get install --no-install-recommends -qy collaboraoffice-desktop
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="collaboraoffice"
ENV PROCESS_NAME="collaboraoffice"
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
