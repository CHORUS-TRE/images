# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG CHORUS_ASSISTANT_URL
ARG MODEL

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    apt-transport-https \
    ca-certificates \
    curl \
    gpg \
    python3 \
    python3-pip

RUN ln -s /usr/bin/python3 /usr/bin/python && \
    python -m pip config set global.break-system-packages true

RUN pip install open-webui

RUN curl -L https://ollama.com/download/ollama-linux-amd64.tgz -o ollama-linux-amd64.tgz && \   
    tar -C /usr -xzf ollama-linux-amd64.tgz && \
    rm ollama-linux-amd64.tgz

RUN if [ -n "${MODEL}" ]; then \
    ollama serve & \
    sleep 15 && \
    ollama pull ${MODEL}; \
fi

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy software-properties-common && \
    add-apt-repository ppa:mozillateam/ppa && \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy firefox-esr

ENV APP_SPECIAL="no"
ENV APP_CMD="firefox-esr ${CHORUS_ASSISTANT_URL}"
ENV PROCESS_NAME="chorus-assistant"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 


# Since docker entrypoint scripts typically follow a lexicographical (alphabetical) 
# sorting order when executing scripts in the entrypoint directory, numbers at the
# start of filenames are commonly used to control the execution order. So in our 
# case we just copy the create-kiosk-config.sh script to the entrypoint directory 
# without number and it will be executed after all other scripts.
ENV APP_NAME=${APP_NAME}
ENV CHORUS_ASSISTANT_URL=${CHORUS_ASSISTANT_URL}
COPY ./start.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]
