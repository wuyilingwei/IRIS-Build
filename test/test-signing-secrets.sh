#!/usr/bin/env bash
set -euo pipefail

workflow="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.github/workflows/build.yml"

if rg -n 'IRIS_MACOS_SIGNING_P12_BASE64|IRIS_MACOS_SIGNING_PASSWORD' "$workflow"; then
  echo 'workflow still references platform-specific signing secrets' >&2
  exit 1
fi

rg -q 'secrets\.IRIS_SIGNING_P12_BASE64' "$workflow"
rg -q 'secrets\.IRIS_SIGNING_PASSWORD' "$workflow"
rg -q 'IRIS_SIGNING_CERT_BASE64: \$\{\{ secrets\.IRIS_SIGNING_P12_BASE64 \}\}' "$workflow"
rg -q 'IRIS_SIGNING_CERT_PASSWORD: \$\{\{ secrets\.IRIS_SIGNING_PASSWORD \}\}' "$workflow"

echo 'signing secrets use platform-neutral names and existing runtime env mappings'
