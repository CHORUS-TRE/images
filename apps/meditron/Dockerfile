# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG WEBUI_URL

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy software-properties-common && \
    add-apt-repository ppa:mozillateam/ppa && \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy firefox-esr

ENV APP_SPECIAL="no"
ENV APP_CMD="firefox-esr -new-window ${WEBUI_URL}"
ENV PROCESS_NAME="firefox"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 

ENV APP_NAME=${APP_NAME}
ENV WEBUI_URL=${WEBUI_URL}

ENTRYPOINT ["/docker-entrypoint.sh"]
