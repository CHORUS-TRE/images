# syntax=docker/dockerfile:1
FROM harbor.build.chorus-tre.ch/docker_proxy/library/ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_NAME
ARG APP_VERSION
ARG APP_PKG_REL

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    curl gpg gpg-agent software-properties-common \
    build-essential cmake dirmngr file libssl-dev libpq5 \
    libclang-dev libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libgtk-3-0 libasound2t64 gfortran liblapack-dev \
    libopenblas-dev libpng-dev libxkbcommon-x11-0 && \
    curl https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /etc/apt/keyrings/cran-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/cran-archive-keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" > /etc/apt/sources.list.d/cran.list && \
    apt-get update -qy && \
    apt-get install --no-install-recommends -y r-base r-cran-rstan r-cran-tidyverse r-cran-devtools && \
    curl -sSO https://download1.rstudio.org/electron/jammy/amd64/rstudio-${APP_VERSION}-${APP_PKG_REL}-amd64.deb && \
    dpkg -i rstudio-${APP_VERSION}-${APP_PKG_REL}-amd64.deb && \
    rm -rf rstudio-${APP_VERSION}-${APP_PKG_REL}-amd64.deb && \
    curl -sSL https://github.com/Mikata-Project/ggthemr/archive/refs/heads/master.tar.gz | tar -xz -C /usr/local/lib/R/site-library && \
    mv /usr/local/lib/R/site-library/ggthemr-master /usr/local/lib/R/site-library/ggthemr && \
    apt-get remove -y --purge curl gpg && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="rstudio --no-sandbox"
ENV PROCESS_NAME="rstudio"
ENV APP_DATA_DIR_ARRAY=".r R .config/rstudio .config/R .local/share/rstudio"
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=true \
    /tmp/core_scripts/shared/chorus-utils.sh && \
    cp /tmp/core_scripts/app/docker-entrypoint.sh / && \
    cp /tmp/core_scripts/app/2-symlink-appdata.sh /docker-entrypoint.d/
    
ENTRYPOINT ["/docker-entrypoint.sh"]
