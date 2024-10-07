# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

ARG APP_VERSION

RUN <<EOT
  #!/bin/bash -xe -o -pipefail
  rm -f /etc/apt/apt.conf.d/docker-clean
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache
EOT

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  bash -xe -o pipefail <<EOT
  apt-get update -qy
  apt-get install --no-install-recommends -qy \
    ca-certificates \
    curl \
    gpg \
    lsb-release

  curl -fsSL https://apt.fury.io/wez/gpg.key | \
    gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | \
    tee /etc/apt/sources.list.d/wezterm.list

  apt-get update -qy
EOT

# The sub command is evaluated first in the bash multiline setup.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  version="$(apt-cache madison wezterm | grep -o "${APP_VERSION}-[0-9]*-[a-f0-9]*")" && \
  apt-get install -qy --no-install-recommends \
    libegl-dev \
    wezterm=${version}

ENV APP_SPECIAL="no"
ENV APP_CMD="wezterm"
ENV PROCESS_NAME="wezterm"
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
