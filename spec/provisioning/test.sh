#!/bin/bash

set -e -o pipefail -x

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ -z "$TEST_NAME" ]; then
  echo "Error: You must specify TEST_NAME" >&2
  exit 1
fi

IMAGE_NAME="mstrap-$TEST_NAME"
DOCKERFILE_NAME="$SCRIPT_DIR/docker/$TEST_NAME.Dockerfile"

export DOCKER_BUILDKIT=1

docker build \
  --platform "$TARGET_OS/$TARGET_ARCH" \
  --file "$DOCKERFILE_NAME" \
  -t "$IMAGE_NAME" \
  $SCRIPT_DIR/docker

docker run \
  --rm \
  --platform "$TARGET_OS/$TARGET_ARCH" \
  -v $(pwd):/workspace:ro \
  -e BUILD_DIR=$BUILD_DIR \
  $IMAGE_NAME
