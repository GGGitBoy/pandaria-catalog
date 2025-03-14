#!/usr/bin/env bash
#
# @file 1-Adapt-hardcoded-references-for-Application-Collection.sh
# @brief Adapt values.yaml to Application Collection
# @description Patch the values.yaml file of the kiali Helm chart in order
#   or the documentation to be valid for the Application Collection.
#
# @noargs
#
# @env PACKAGE_PATH string Path to the package in the repository.
#
# @require sed

# Strict mode
set -euo pipefail

# Debug mode
# set -x

GIT_ROOT_PATH="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT_PATH/scripts/functions.sh"

check_required_environment_variables PACKAGE_PATH
check_required_programs sed

pushd "$GIT_ROOT_PATH/packages/$PACKAGE_PATH" &>/dev/null

# Remove any reference to quay's distribution in the values.yaml file
VALUES_FILE="values.yaml"
QUAY_REFERENCE="quay.io/repository/kiali/kiali?tab=tags"
APPLICATION_COLLECTION_REFERENCE="apps.rancher.io/artifacts?name=kiali"
log "Patching values.yaml"
VALUES_CONTENTS="$(<"$VALUES_FILE")"

echo "${VALUES_CONTENTS//$QUAY_REFERENCE/$APPLICATION_COLLECTION_REFERENCE}" \
    >"$VALUES_FILE"
