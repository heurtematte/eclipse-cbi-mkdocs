#!/bin/bash

# SPDX-FileCopyrightText: 2022 eclipse foundation
# SPDX-License-Identifier: EPL-2.0

# Bash strict-mode
set -o errexit
set -o nounset
#set -o pipefail


environment="${1:-}"

if [ -z "${environment}" ]; then
  echo "You must provide an 'environment' name argument"
  exit 1
fi

tk apply "environments/chat-elementweb/${environment}"
kubectl rollout restart -n chat-elementweb-"${environment}" deployment elementweb
kubectl rollout status -n chat-elementweb-"${environment}" deployment elementweb