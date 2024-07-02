# syntax=docker/dockerfile:1
FROM ubuntu:22.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]

FROM ubuntu:24.04 AS base

RUN <<EOT
  #!/bin/bash -xe -o -pipefail
  rm -f /etc/apt/apt.conf.d/docker-clean
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache
EOT

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  bash -xe -o pipefail <<EOT
  apt-get update -qy
  apt-get install --no-install-recommends -qy \
    ca-certificates \
    curl \
    gpg \
    lsb-release
EOT

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  bash -xe -o pipefail <<EOT

  curl -fsSL https://apt.fury.io/wez/gpg.key | \
    gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | \
    tee /etc/apt/sources.list.d/wezterm.list

  apt-get update -qy
  apt-get install -qy --no-install-recommends \
    libegl-dev \
    wezterm

EOT

USER 1000
CMD ["wezterm"]
