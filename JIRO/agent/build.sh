#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

export LOG_LEVEL="${LOG_LEVEL:-600}"
# shellcheck disable=SC1090
. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.bashtools/bashtools"

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PATH="${SCRIPT_FOLDER}/.jsonnet:${SCRIPT_FOLDER}/.dockertools:${PATH}"

AGENTS_JSONNET="${1}"
AGENT_ID="${2:-}"
PUSH_IMAGES="${PUSH_IMAGES:-"true"}"

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"
PATH="${SCRIPT_FOLDER}/.dockertools:${PATH}"

BUILD_DIR="${SCRIPT_FOLDER}/target/"
AGENTS_JSON="${BUILD_DIR}/agents.json"

# gen the computed agents.json (mainly for .agents[])
mkdir -p "${BUILD_DIR}/"
jsonnet "${AGENTS_JSONNET}" > "${AGENTS_JSON}"

build_agent_variant() {
  local id="${1}"
  local variant="${2}"
  local agent_config="${3}"
  local config_dir="${BUILD_DIR}/${id}/${variant}"
  local config="${config_dir}/variant.json"

  INFO "Building jiro-agent '${id}' - variant ${variant}"

  mkdir -p "${config_dir}"
  jq -r '.variants["'"${variant}"'"]' "${agent_config}" > "${config}"

  jq -r '.docker.dockerfile' "${config}" > "${config_dir}/Dockerfile"

  local image tag 
  image="$(jq -r '.spec.docker.registry' "${agent_config}")/$(jq -r '.spec.docker.repository' "${agent_config}")/$(jq -r '.spec.docker.image' "${agent_config}")"
  tag="$(jq -r '.docker.tag' "${config}")"

  local aliases="${image}:${tag}"
  for alias in $(jq -r '.docker.aliases[]' "${config}"); do 
    aliases="${aliases},${alias}"
  done
  
  INFO "Building docker image ${image}:${tag} (push=${PUSH_IMAGES})"
  dockerw build2 "${aliases}" "${config_dir}/Dockerfile" "${config_dir}" "${PUSH_IMAGES}" |& TRACE
}

build_agent() {
  local id="${1}"
  local config_dir="${BUILD_DIR}/${id}"
  local config="${config_dir}/agent.json"

  INFO "Building jiro-agent spec '${id}'"

  mkdir -p "${config_dir}"
  jq -r '.["'"${id}"'"]' "${AGENTS_JSON}" > "${config}"
  jq -r '.spec.docker.dockerfile' "${config}" > "${config_dir}/Dockerfile"

  local image tag context
  image="$(jq -r '.spec.docker.registry' "${config}")/$(jq -r '.spec.docker.repository' "${config}")/$(jq -r '.spec.docker.image' "${config}")"
  tag="$(jq -r '.spec.docker.tag' "${config}")"
  context="$(jq -r '.spec.docker.context' "${config}")"

  INFO "Building docker image ${image}:${tag} (push=${PUSH_IMAGES})"
  dockerw build2 "${image}:${tag}" "${config_dir}/Dockerfile" "${context}" "${PUSH_IMAGES}" |& TRACE

  for variant in $(jq -r '.variants | keys[]' "${config}"); do
    build_agent_variant "${id}" "${variant}" "${config}"
  done
}

if [[ -n "${AGENT_ID}" ]]; then
  build_agent "${AGENT_ID}" 
else 
  for id in $(jq -r '. | keys[]' "${AGENTS_JSON}"); do
    build_agent "${id}"
  done
fi
