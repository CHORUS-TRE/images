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
    ca-certificates curl unzip libxkbcommon-x11-0 libxcb-keysyms1 \
    libglib2.0-0 libdbus-1-3 libxcb-icccm4 \
    libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-cursor0 fontconfig && \
    curl -sSOL https://github.com/floriansipp/TRCAnonymizer/releases/download/V${APP_VERSION}/TRCAnonymizer.${APP_VERSION}.linux64.zip && \
    mkdir ./install && \
    unzip -q -d ./install TRCAnonymizer.${APP_VERSION}.linux64.zip && \
    chmod -R 757 ./install/TRCAnonymizer.${APP_VERSION}.linux64 && \
    rm TRCAnonymizer.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/TRCAnonymizer.${APP_VERSION}.linux64/TRCAnonymizer"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/TRCAnonymizer.${APP_VERSION}.linux64/TRCAnonymizer"
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
