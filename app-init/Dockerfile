# syntax=docker/dockerfile:1
# Trusted init container for Chorus workbench user setup
# This container runs as root with limited capabilities to create users and setup directories
# Security: Only use trusted, audited code in this image

FROM ubuntu:24.04

# Install minimal dependencies for user creation and directory setup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        passwd \
        coreutils \
        findutils && \
    rm -rf /var/lib/apt/lists/*

# Create directory for entrypoint scripts
RUN mkdir -p /docker-entrypoint.d

# Copy entrypoint scripts from core (permissions preserved from source)
COPY core/init/docker-entrypoint-init.sh /docker-entrypoint-init.sh
COPY core/init/1-create-user.sh /docker-entrypoint.d/1-create-user.sh
COPY core/init/2-symlink-workspace.sh /docker-entrypoint.d/2-symlink-workspace.sh

# This entrypoint runs ONLY during init container phase
ENTRYPOINT ["/docker-entrypoint-init.sh"]
