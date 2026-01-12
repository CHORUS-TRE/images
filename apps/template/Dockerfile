# syntax=docker/dockerfile:1

# ==============================================================================
# BUILDER STAGE
#
# This stage is for building the application and installing dependencies.
# It contains build tools that will not be included in the final image.
# ==============================================================================
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04 AS builder
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

# Install essential build tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
        build-essential \
        curl \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Placeholder for application-specific build steps ---
# For example, download source code, compile, install python packages, etc.
# RUN git clone https://github.com/example/my-app.git /app
# RUN pip install -r /app/requirements.txt
# ---------------------------------------------------------


# ==============================================================================
# FINAL STAGE
#
# This is the lean, production-ready image.
# It only contains the application and its runtime dependencies.
# ==============================================================================
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

# These arguments are passed from the build.sh script
ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/${APP_NAME}
ARG DEBIAN_FRONTEND=noninteractive

# Create a non-root user for the application.
# The UID/GID will be overridden at runtime by the Chorus platform,
# but creating the user is still a good practice.
RUN useradd --create-home --shell /bin/bash appuser

# --- Placeholder for copying application from builder stage ---
# COPY --from=builder /app /opt/app
# --------------------------------------------------------------

# --- Chorus Integration ---
# These environment variables are used by the Chorus entrypoint scripts.
#
# APP_CMD: The command to start your application.
# PROCESS_NAME: A short name for the process, used for display.
# APP_DATA_DIR_ARRAY: Space-separated list of directories inside $HOME to persist.
#                     These will be symlinked to persistent storage.
# DATA_DIR_ARRAY: (Optional) For other data directories.
#
ENV APP_SPECIAL="no"
ENV APP_CMD="echo 'Application not configured. Please set APP_CMD.'"
ENV PROCESS_NAME="template-app"
ENV APP_DATA_DIR_ARRAY=".config/template-app .local/share/template-app"
ENV DATA_DIR_ARRAY=""

# Install runtime dependencies and Chorus utilities.
# `chorus-utils.sh` installs `libnss-wrapper` and other essentials.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
        # Add any runtime-specific packages here (e.g., libgl1, libxrender1)
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# The `core` directory is copied into the build context by build.sh
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    # This script installs libnss-wrapper and other utilities
    /tmp/core_scripts/shared/chorus-utils.sh && \
    # Copy the standard application entrypoint
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    # This script handles symlinking the persistent directories defined in APP_DATA_DIR_ARRAY
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/

# Switch to the non-root user
USER appuser

# The Chorus entrypoint script will execute, setting up the user environment
# before running the command specified in the CMD instruction.
ENTRYPOINT ["/docker-entrypoint.sh"]

# Default command to run. This is often a shell, allowing users to
# execute the application manually or explore the container.
CMD ["/bin/bash"]
