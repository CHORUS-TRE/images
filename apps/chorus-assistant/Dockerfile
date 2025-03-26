# syntax=docker/dockerfile:1
FROM thelocallab/ollama-openwebui
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
#     --mount=type=cache,target=/var/lib/apt,sharing=locked \
#     apt-get update -qy && \
#     apt-get install --no-install-recommends -qy \
#         ca-certificates \
#         curl \
#         wget \
#         git \
#         build-essential

# # Install Ollama with architecture detection
# RUN ARCH=$(uname -m) && \
#     if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
#         echo "Installing Ollama for ARM64 architecture"; \
#     else \
#         echo "Installing Ollama for x86_64 architecture"; \
#     fi && \
#     curl -fsSL https://ollama.com/install.sh | sh

# # RUN /usr/local/bin/ollama pull llama3

# # Set environment variables
# ENV APP_SPECIAL="no"
# ENV APP_CMD="/usr/local/bin/ollama serve"
# ENV PROCESS_NAME="ollama"
# ENV APP_DATA_DIR_ARRAY=".ollama"
# ENV DATA_DIR_ARRAY=""

# # Create a startup script to ensure Ollama keeps running and binds to all interfaces
# RUN echo '#!/bin/bash\n\
# echo "Starting Ollama server..."\n\
# # Explicitly bind to all interfaces (0.0.0.0) to allow external access\n\
# ollama serve --host 0.0.0.0 &\n\
# OLLAMA_PID=$!\n\
# echo "Ollama server started with PID: $OLLAMA_PID"\n\
# \n\
# # Keep the container running\n\
# trap "kill $OLLAMA_PID; exit" SIGINT SIGTERM\n\
# wait $OLLAMA_PID\n\
# ' > /start-ollama.sh && chmod +x /start-ollama.sh

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 


ENV APP_NAME=${APP_NAME}

ENTRYPOINT ["/docker-entrypoint.sh"]
