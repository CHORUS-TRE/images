#!/bin/sh

APP_NAME="zenodo"
APP_VERSION="8.2.0"
PKG_REL="1"

# If the APP_VERSION is bumped, reset the PKG_REL
# otherwhise, please bump the PKG_REL on any changes.
VERSION="${APP_VERSION}-${PKG_REL}"

REGISTRY="${REGISTRY:=registry.build.chorus-tre.local}"

# Use `registry` to build and push
OUTPUT="type=${OUTPUT:-docker}"

# curl -sSJLO https://github.com/zenodo/zenodo-rdm/archive/refs/tags/v${APP_VERSION}.zip

# unzip -q zenodo-rdm-${APP_VERSION}.zip   

pushd zenodo-rdm-${APP_VERSION}

# Tip: use `BUILDKIT_PROGRESS=plain` to see more.

docker buildx build \
    --pull \
    -t ${REGISTRY}/${APP_NAME} \
    -t ${REGISTRY}/${APP_NAME}:${VERSION} \
    --label "APP_NAME=${APP_NAME}" \
    --label "APP_VERSION=${APP_VERSION}" \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    # --build-arg "INVENIO_ACCOUNTS_SESSION_REDIS_URL=redis://cache:6379/1" \
    # --build-arg "INVENIO_COMMUNITIES_IDENTITIES_CACHE_REDIS_URL=redis://cache:6379/1" \
    # --build-arg "INVENIO_BROKER_URL=amqp://guest:guest@mq:5672/" \
    # --build-arg "INVENIO_CACHE_REDIS_URL=redis://cache:6379/0" \
    # --build-arg "INVENIO_CACHE_TYPE=redis" \
    # --build-arg "INVENIO_CELERY_BROKER_URL=amqp://guest:guest@mq:5672/" \
    # --build-arg "INVENIO_CELERY_RESULT_BACKEND=redis://cache:6379/2" \
    # --build-arg "INVENIO_SEARCH_HOSTS=search:9200" \
    # --build-arg "INVENIO_SECRET_KEY=CHANGE_ME" \
    # --build-arg "INVENIO_SQLALCHEMY_DATABASE_URI=postgresql+psycopg2://zenodo:zenodo@db:5432/zenodo" \
    # --build-arg "INVENIO_WSGI_PROXIES=2" \
    # --build-arg "INVENIO_RATELIMIT_STORAGE_URL=redis://cache:6379/3" \
    # --build-arg "INVENIO_SITE_UI_URL=https://127.0.0.1" \
    # --build-arg "INVENIO_SITE_API_URL=https://127.0.0.1/api" \
    --output=$OUTPUT \
    .

popd

# rm -rf zenodo-rdm-${APP_VERSION}
# rm -rf zenodo-rdm-${APP_VERSION}.zip