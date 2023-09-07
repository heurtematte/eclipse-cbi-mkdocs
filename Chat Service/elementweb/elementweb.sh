#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2022 eclipse foundation
# SPDX-License-Identifier: EPL-2.0

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# shellcheck disable=SC1091
 . "${SCRIPT_FOLDER}/scripts/log.sh"

action="${1:-}"
environment="${2:-}"
debug="${3:-}"
dry="${4:-}"

if [ -z "${action}" ]; then
  log error "You must provide an 'action' name argument"
  exit 1
fi

if [ -z "${environment}" ]; then
  log error "You must provide an 'environment' name argument"
  exit 1
fi

ENV_DEBUG=(--env SCRIPT_DEBUG="false")
[[ -n "${debug}" ]] && ENV_DEBUG=(--env SCRIPT_DEBUG="true")

ENV_DRY=(--env DRY="false")
[[ -n "${dry}" ]] && ENV_DRY=(--env DRY="true")

[[ "${action}" == "show" ]] && action="${action} --dangerous-allow-redirect"

# log info  "############################ START matrix on ${environment} ############################"

docker run \
    -v "${PWD}":/app \
    -v ~/.cbi/config:/home/tanka/.cbi/config \
    -v ~/.kube/config:/home/tanka/.kube/config \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --env KUBECONFIG=/home/tanka/.kube/config \
    "${ENV_DEBUG[@]}" \
    "${ENV_DRY[@]}" \
    --network host \
    tanka "${action}" "${environment}"

# log info  "############################ END matrix ############################"
