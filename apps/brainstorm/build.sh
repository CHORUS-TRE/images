#!/bin/sh

docker build -t registry.dip-dev.thehip.app/brainstorm:latest --build-arg APP_NAME=brainstorm --build-arg VERSION=R2022b --build-arg UPDATE=7 .
