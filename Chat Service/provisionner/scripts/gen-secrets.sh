#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************


set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# shellcheck disable=SC1091
 . "${SCRIPT_FOLDER}/log.sh"
# shellcheck disable=SC1091
 . "${SCRIPT_FOLDER}/pass_wrapper.sh"

environment="${1:-}"

start=$(date +"%s")

log info  "############################ START secret ${environment} ############################"

if [ -z "${environment}" ]; then
  log error "You must provide an 'environment' argument ('dev', 'prod' or 'staging')"
  exit 1
fi

SECRET_DIR="${SCRIPT_FOLDER}/../environments/chat-matrix/${environment}/.secrets"
mkdir -p "${SECRET_DIR}"

create_secret() {
  local service="${1:-}"
  secretEnvPath="IT/services/chat-service/${service}/${environment}"
  secretsList="$(passw it "${secretEnvPath}")"
  localJsonOuput="{}"
  for secret in ${secretsList}; do
    if [[ "${secret}" != "${secretEnvPath}" ]]; then
      secret=${secret//├── }
      secret=${secret//└── }
      secretPath="${secretEnvPath}/${secret}"
      realSecret=$(passw it "$secretPath")
      secretJsonOuput=$(jq --null-input --arg secretKey "$secret" --arg secretValue "$realSecret" '.[$secretKey]+= $secretValue')
      localJsonOuput=$(echo "${localJsonOuput}" "${secretJsonOuput}" | jq -s add)
    fi
  done
  JSON_OUTPUT=$(cat <<EOF
{
  "${service}": ${localJsonOuput}
}
EOF
)
}

JSON_OUTPUT_FINAL="{}"
JSON_OUTPUT="{}"
create_secret "chat-service-sync"
JSON_OUTPUT_FINAL=$(echo "${JSON_OUTPUT_FINAL}" "${JSON_OUTPUT}" | jq -s add)


cat <<EOG > "${SECRET_DIR}/secrets.jsonnet"
{
  _secret+:: ${JSON_OUTPUT_FINAL}
}
EOG

end=$(date +"%s")
runtime=$(echo "$end - $start" | bc -l)
log info  "############################ END gen-secret in ${runtime}s ############################"


