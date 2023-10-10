#!/bin/bash

set -eu -o pipefail

export BUNDLE_PATH="~/.bundle"
export GEM_HOME="~/.gems"
export USER="$(whoami)"
export SHELL=/bin/bash

MSTRAP_FLAGS=${MSTRAP_FLAGS:-"--debug"}
WORKSPACE=/workspace

mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

echo "-> Running mstrap..."
(yes 2>/dev/null || true) | $WORKSPACE/$BUILD_DIR/mstrap $MSTRAP_FLAGS

echo "-> Activating ~/.mstrap/env.sh"
if [ -f "$HOME/.mstrap/env.sh" ]; then
  source "$HOME/.mstrap/env.sh"
else
  echo "Error: ~/.mstrap/env.sh is missing or is not executable" >&2
  exit 1
fi

echo "-> Running provisioning tests..."
cd $WORKSPACE && make check-provisioning
