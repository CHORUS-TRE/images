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
    apt-get install --no-install-recommends -qy ca-certificates curl \
    x11-common libasound2t64 desktop-file-utils gstreamer1.0-libav \
    gstreamer1.0-plugins-ugly libxss1 libatk1.0-0 libgtk-3-0 libcairo2 \
    libxkbcommon-x11-0 fonts-dejavu fonts-liberation fonts-crosextra-carlito \
    xdg-utils libavfilter9 libnss3 gsettings-desktop-schemas && \
    curl -ssOL https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v${APP_VERSION}/onlyoffice-desktopeditors_amd64.deb && \
    dpkg -i onlyoffice-desktopeditors_amd64.deb && \
    rm onlyoffice-desktopeditors_amd64.deb && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="onlyoffice-desktopeditors"
ENV PROCESS_NAME="/opt/onlyoffice/desktopeditors/DesktopEditors"
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
