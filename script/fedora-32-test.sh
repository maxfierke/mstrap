#!/bin/bash

set -e -o pipefail

IMAGE_NAME="mstrap-f32-test"

export DOCKER_BUILDKIT=1

docker build \
  --file docker/fedora-32-test.Dockerfile \
  -t $IMAGE_NAME \
  docker

docker run \
  --rm \
  -v $(pwd)/docker/config.hcl:/home/mstrap/.mstrap/config.hcl \
  -v $(pwd):/workspace \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  -e IMAGE_NAME=$IMAGE_NAME \
  $IMAGE_NAME
