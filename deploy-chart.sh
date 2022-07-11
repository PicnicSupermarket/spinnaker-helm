#!/usr/bin/env bash

set -e -u -o pipefail

NEXUS_USERNAME="${NEXUS_USERNAME:?NEXUS_USERNAME not specified or empty}"
NEXUS_PASSWORD="${NEXUS_PASSWORD:?NEXUS_PASSWORD not specified or empty}"
CHARTS_DIR="${1:-charts}"

CHART_DIR="${CHARTS_DIR}/spinnaker"

# Ensure all dependent charts are pulled.
helm3 dependency build "${CHART_DIR}"

# Package the chart.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "${TMP_DIR}"' INT TERM HUP EXIT
helm3 package "${CHART_DIR}" --destination "${TMP_DIR}"
find "${TMP_DIR}" -name '*.tgz' -exec \
    curl --fail-with-body \
    -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" \
    https://nexus.global.picnicinternational.com/repository/helm/ \
    --upload-file {} +;

echo "Published successfully"
