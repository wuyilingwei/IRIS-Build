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

rg -q "if: matrix.os == 'macos-latest'" "$workflow"
rg -q 'IRIS_SIGNING_ROOT_SHA1: 8601bb53dfc44d12d26f0e513ced84673b874cea' "$workflow"
rg -q 'IRIS_SIGNING_ROOT_PATH: certificates/iris-internal-signing-root.cert.pem' "$workflow"
rg -q 'sudo -n /usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain' "$workflow"
rg -q 'sudo -n /usr/bin/security delete-certificate -Z "\$IRIS_SIGNING_ROOT_SHA1" /Library/Keychains/System.keychain' "$workflow"
rg -q "if: always\(\) && matrix.os == 'macos-latest'" "$workflow"
test "$(rg -c '/usr/bin/perl -e' "$workflow")" -eq 2
if rg -n 'add-trusted-cert.*IRIS_SIGNING_P12|add-trusted-cert.*iris-signing\.p12' "$workflow"; then
  echo 'workflow must trust the public root, not the P12 leaf' >&2
  exit 1
fi

echo 'signing secrets and macOS ephemeral root trust are constrained correctly'
