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
        curl ca-certificates && \
    curl -fsSL https://repository.salamek.cz/deb/salamek.gpg | tee /usr/share/keyrings/salamek-archive-keyring.gpg > /dev/null && \
    echo "deb     [signed-by=/usr/share/keyrings/salamek-archive-keyring.gpg] https://repository.salamek.cz/deb/pub all main" | tee /etc/apt/sources.list.d/salamek.cz.list && \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy qiosk && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/start-qiosk.sh"
ENV PROCESS_NAME="chrome"
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
ENV KIOSK_URL="https://www.chorus-tre.ch"
COPY start-qiosk.sh /apps/${APP_NAME}

ENTRYPOINT ["/docker-entrypoint.sh"]
