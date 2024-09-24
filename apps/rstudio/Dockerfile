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
    software-properties-common dirmngr \
    curl wget gpg gpg-agent libssl-dev libpq5 libclang-dev \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libgtk-3-0 libasound2t64 build-essential cmake file \
    gfortran liblapack-dev libopenblas-dev libpng-dev \
    libxkbcommon-x11-0 && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt-get install --no-install-recommends -y r-base r-cran-rstan r-cran-tidyverse && \
    curl -sSO https://download1.rstudio.org/electron/jammy/amd64/rstudio-${APP_VERSION}-375-amd64.deb && \
    dpkg -i rstudio-${APP_VERSION}-375-amd64.deb && \
    rm -rf rstudio-${APP_VERSION}-375-amd64.deb && \
    R -e "install.packages('devtools', repos='http://cloud.r-project.org')" && \
    R -e "devtools::install_github('Mikata-Project/ggthemr')" && \
    apt-get remove -y --purge curl gpg wget && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="no"
ENV APP_CMD="rstudio"
ENV PROCESS_NAME="rstudio"
ENV APP_DATA_DIR_ARRAY=".r R .config/rstudio .config/R .local/share/rstudio"
ENV DATA_DIR_ARRAY=""

# Install vgl + whatever is necessary for chorus use
RUN --mount=type=bind,source=./core,target=/tmp/core_scripts,readonly=false \
    pushd /tmp/core_scripts && \
    ./utilities/chorus-utils.sh && \
    mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    popd 
    
ENTRYPOINT ["/docker-entrypoint.sh"]
