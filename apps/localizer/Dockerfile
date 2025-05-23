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
    apt-get install --no-install-recommends -qy ca-certificates curl gpg lsb-release \
    unzip libgomp1 libglib2.0-0 libdbus-1-3 libfftw3-single3 \
    libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
    libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 \
    libxcb-xinput0 libxcb-shape0 fontconfig && \
    curl -sSOL https://github.com/CRNL-Eduwell/Localizer/releases/download/V${APP_VERSION}/Localizer.${APP_VERSION}.linux64.zip && \
    mkdir ./install && \
    unzip -q -d ./install Localizer.${APP_VERSION}.linux64.zip && \
    chmod -R 757 ./install/Localizer.${APP_VERSION}.linux64 && \
    rm Localizer.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/Localizer.${APP_VERSION}.linux64/Localizer"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/Localizer.${APP_VERSION}.linux64/Localizer"
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
