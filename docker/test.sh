#!/bin/bash

set -eu -o pipefail

export USER="$(whoami)"
export SHELL=/bin/bash

MSTRAP_FLAGS=${MSTRAP_FLAGS:-"--debug"}
WORKSPACE=/workspace

echo "-> Adding SSH keys from agent..."
ssh-add -l
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

echo "-> Running mstrap for first time..."
$WORKSPACE/bin/mstrap $MSTRAP_FLAGS

echo "-> Loading up mstrap env.sh..."
source ~/.mstrap/env.sh

echo "-> Continuing second run of mstrap..."
$WORKSPACE/bin/mstrap $MSTRAP_FLAGS

echo "-> Running provisioning tests..."
cd $WORKSPACE && make check-provisioning
