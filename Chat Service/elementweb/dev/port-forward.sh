#!/bin/bash

# SPDX-FileCopyrightText: 2022 eclipse foundation
# SPDX-License-Identifier: EPL-2.0

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

environment="-${1:-}"
[[ "$environment" == "-" ]] && echo "Please provide environment as first argument" && exit 1
[[ "$environment" == "-prod" ]] && environment=""

kubectl port-forward deployment/elementweb 8080:8080 -n "chat-elementweb${environment}" 

