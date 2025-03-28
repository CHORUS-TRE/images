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
    tar -C /usr -xzf ollama-linux-amd64.tgz 

RUN ollama serve & \
    sleep 10 && \
    ollama pull qwen2.5:3b

ENV APP_SPECIAL="no"
ENV APP_CMD="ollama serve & && sleep 15 && open-webui serve"
ENV PROCESS_NAME="chorus-assistant"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV GRADIO_SERVER_NAME="0.0.0.0"

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 

ENV APP_NAME=${APP_NAME}

ENTRYPOINT ["/docker-entrypoint.sh"]
