#!/bin/sh

docker build -t brainstorm:latest --build-arg VERSION=R2022b --build-arg UPDATE=7 .
