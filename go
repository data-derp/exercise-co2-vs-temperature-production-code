#!/usr/bin/env bash

set -e
script_dir=$(cd "$(dirname "$0")" ; pwd -P)

goal_setup-workflow() {
  ${script_dir}/setup-workflow "$@"
}

goal_pull-dev-container() {
  pushd "${script_dir}" > /dev/null
    docker pull ghcr.io/data-derp/dev-container:master
  popd > /dev/null
}

TARGET=${1:-}
if type -t "goal_${TARGET}" &>/dev/null; then
  "goal_${TARGET}" ${@:2}
else
  echo "Usage: $0 <goal>

goal:
    setup-workflow                        - Sets up Github Actions workflow
    pull-dev-container                    - Pulls dev container
"
  exit 1
fi
