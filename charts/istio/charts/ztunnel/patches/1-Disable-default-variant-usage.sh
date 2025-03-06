#!/usr/bin/env bash
#
# @file 1-Disable-default-variant-usage.sh
# @brief Disable images variant usage in profile files.
# @description Disable images variant usage in `profile-ambient.yaml` and 
#   `profile-openshift-ambient.yaml` files.
#
# @noargs
#
# @env PACKAGE_PATH string Path to the package in the repository.
#
# @require yq

# Strict mode
set -euo pipefail

# Debug mode
# set -x

GIT_ROOT_PATH="$(git rev-parse --show-toplevel)"
source "${GIT_ROOT_PATH}/scripts/functions.sh"

check_required_environment_variables PACKAGE_PATH
check_required_programs yq

FILES_PATH="${GIT_ROOT_PATH}/packages/${PACKAGE_PATH}/files"
yq eval -i '.global.variant="" | .variant=""' \
    "${FILES_PATH}/profile-ambient.yaml"
