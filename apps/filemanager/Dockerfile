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
    libgtk2.0-bin libgtk-3-bin dbus-x11 pcmanfm-qt \
    #pdf viewer \
    qpdfview \
    #text editor \
    featherpad \
    #libreoffice \
    libreoffice && \
    apt-get remove -y --purge && \
    apt-get autoremove -y --purge

ENV APP_NAME=${APP_NAME}
ENV APP_SPECIAL="no"
ENV APP_CMD="pcmanfm-qt"
ENV PROCESS_NAME="pcmanfm-qt"
ENV APP_DATA_DIR_ARRAY=".config/pcmanfm-qt .config/libreoffice"
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/docker-entrypoint-main.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    mv entrypoint/2-copy-config.sh /docker-entrypoint.d && \
    mv entrypoint/3-symlink-appdata.sh /docker-entrypoint.d && \
    chmod +x /docker-entrypoint.sh /docker-entrypoint-main.sh && \
    popd

# Copy config files
COPY ./config/settings.conf /apps/${APP_NAME}/config/
COPY ./config/init-filemanager.sh /docker-entrypoint.d/

# Main entrypoint for application (runs as non-root user set by Kubernetes)
ENTRYPOINT ["/docker-entrypoint-main.sh"]
