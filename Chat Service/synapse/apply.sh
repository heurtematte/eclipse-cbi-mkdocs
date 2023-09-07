#!/bin/bash

# SPDX-FileCopyrightText: 2022 eclipse foundation
# SPDX-License-Identifier: EPL-2.0

# Bash strict-mode
set -o errexit
set -o nounset
#set -o pipefail

SYNAPSE_SERVICES=("synapse" "matrix-media-repo" "synapse-admin" "bot-mjolnir" "appservice-slack" "appservice-policies")

environment="${1:-}"
services="${2:-${SYNAPSE_SERVICES[@]}}"

if [ -z "${environment}" ]; then
  echo "You must provide an 'environment' name argument"
  exit 1
fi

tk apply "environments/chat-matrix/${environment}"

for service in ${services}
do
  kubectl rollout restart -n chat-matrix-"${environment}" deployment "${service}"
  kubectl rollout status -n chat-matrix-"${environment}" deployment "${service}"
done
