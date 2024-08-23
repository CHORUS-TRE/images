# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    ca-certificates curl xdg-utils desktop-file-utils \
    shared-mime-info libswt-gtk-4-java dbus-x11 at-spi2-core && \
    curl -sSL "https://arx.deidentifier.org/?ddownload=2135" -o arxinstaller && \
    mkdir -p ~/.local/share/applications && \
    mkdir -p ~/.local/share/mime/packages && \
    mkdir -p ~/.local/share/icons/hicolor && \
    update-desktop-database ~/.local/share/applications/ && \ 
    update-mime-database ~/.local/share/mime/ && \ 
    gtk-update-icon-cache ~/.local/share/icons/hicolor/ -t && \ 
    chmod 755 arxinstaller && \
    ./arxinstaller --mode unattended && \ 
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge 

ENV APP_SPECIAL="no"
ENV APP_CMD="/opt/ARX-3.9.1/ARX-launcher.run"
ENV PROCESS_NAME="ARX-launcher"
ENV APP_DATA_DIR_ARRAY=".local"
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    pushd /tmp/core_scripts/utilities && \
    ./chorus-utils.sh && \
    popd && mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 
    
ENTRYPOINT ["/docker-entrypoint.sh"]
