#!/bin/sh

docker build -t registry.dip-dev.thehip.app/brainstorm:latest --build-arg APP_NAME=brainstorm --build-arg VERSION=R2022b --build-arg UPDATE=7 .
docker tag registry.dip-dev.thehip.app/brainstorm:latest registry.build.chorus-tre.ch/brainstorm:latest
docker push registry.build.chorus-tre.ch/brainstorm:latest
