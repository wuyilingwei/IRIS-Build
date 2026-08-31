#!/usr/bin/env bash
set -euo pipefail

workflow="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.github/workflows/build.yml"

if rg -n 'IRIS_MACOS_SIGNING_P12_BASE64|IRIS_MACOS_SIGNING_PASSWORD' "$workflow"; then
  echo 'workflow still references platform-specific signing secrets' >&2
  exit 1
fi

if rg -n 'secrets\.IRIS_LEGACY' "$workflow"; then
  echo 'legacy bridge must not add a signing secret' >&2
  exit 1
fi

rg -q 'secrets\.IRIS_SIGNING_P12_BASE64' "$workflow"
rg -q 'secrets\.IRIS_SIGNING_PASSWORD' "$workflow"
rg -q 'IRIS_SIGNING_CERT_PASSWORD: \$\{\{ secrets\.IRIS_SIGNING_PASSWORD \}\}' "$workflow"
rg -q 'IRIS_SIGNING_MIGRATION_PHASE: legacy-bridge' "$workflow"
rg -q 'IRIS_LEGACY_BRIDGE_COMMIT: 9308241a80cbd02b68505ac60dc1848cfb58bcd4' "$workflow"
rg -q 'IRIS_LEGACY_BRIDGE_ROOT_SHA1: 7dbbec289bce316a2163ee3d4f4292836733bd78' "$workflow"
rg -q 'git -C iris-source fetch --no-tags --depth=1 origin' "$workflow"
rg -q 'iris-internal-signing-100y\.p12' "$workflow"
rg -q 'IRIS_SIGNING_CERT_FILE: \$\{\{ runner.temp \}\}/iris-legacy-bridge.p12' "$workflow"
rg -q "IRIS_SIGNING_MIGRATION_PHASE == 'legacy-bridge'" "$workflow"
rg -q "IRIS_SIGNING_MIGRATION_PHASE == 'current'" "$workflow"
rg -q 'IRIS_SIGNING_PROFILE: \$\{\{ env\.IRIS_SIGNING_MIGRATION_PHASE == '\''legacy-bridge'\'' && '\''legacy-bridge'\'' \|\| '\''current'\'' \}\}' "$workflow"
rg -q 'openssl pkcs12 -in "\$RUNNER_TEMP/iris-legacy-bridge.p12" -nokeys' "$workflow"
rg -q 'openssl pkcs12 -legacy -in "\$RUNNER_TEMP/iris-legacy-bridge.p12" -nokeys' "$workflow"
if rg -n "source_sha == '9308241a|source_sha != '9308241a" "$workflow"; then
  echo 'legacy bridge must not select a historical source revision' >&2
  exit 1
fi
if rg -n 'IRIS_LEGACY_BRIDGE_SUPPORT_COMMIT|iris-legacy-bridge\.cert\.pem|git -C iris-source show "\$IRIS_LEGACY_BRIDGE_SUPPORT_COMMIT' "$workflow"; then
  echo 'legacy bridge must build only the dispatched source checkout' >&2
  exit 1
fi
rg -q 'name: Trust legacy-bridge signing root for macOS build' "$workflow"
rg -q 'name: Remove legacy-bridge signing root' "$workflow"
if ! awk '
  /name: Prepare fixed legacy-bridge signing certificate/ { prepare = NR }
  /name: Prepare legacy-bridge signing certificate/ { material = NR }
  /name: Verify signing identity/ { verify = NR }
  END { exit !(prepare < material && material < verify) }
' "$workflow"; then
  echo 'legacy bridge material and signing preparation must precede verification' >&2
  exit 1
fi

rg -q "if: matrix.os == 'macos-latest'" "$workflow"
rg -q 'IRIS_LEGACY_BRIDGE_ROOT_SHA1: 7dbbec289bce316a2163ee3d4f4292836733bd78' "$workflow"
rg -q 'IRIS_LEGACY_BRIDGE_ROOT_PATH: certificates/iris-internal-signing-legacy-bridge.cert.pem' "$workflow"
rg -q 'IRIS_SIGNING_ROOT_SHA1: 8601bb53dfc44d12d26f0e513ced84673b874cea' "$workflow"
rg -q 'IRIS_SIGNING_ROOT_PATH: certificates/iris-internal-signing-root.cert.pem' "$workflow"
rg -q 'sudo -n /usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain' "$workflow"
rg -q 'sudo -n /usr/bin/security delete-certificate -Z "\$IRIS_LEGACY_BRIDGE_ROOT_SHA1" /Library/Keychains/System.keychain' "$workflow"
rg -q "if: always\(\) && matrix.os == 'macos-latest'" "$workflow"
test "$(rg -c '/usr/bin/perl -e' "$workflow")" -eq 4
rg -q 'name: Retain staged installers for failed-build diagnosis' "$workflow"
rg -q "if: always\(\) && hashFiles\('staged-installers/\*\*'\) != ''" "$workflow"
if ! awk '
  /name: Verify signed installers/ { verify = NR }
  /name: Retain staged installers for failed-build diagnosis/ { retain = NR }
  END { exit !(retain > verify) }
' "$workflow"; then
  echo 'diagnostic installer retention must follow signature verification' >&2
  exit 1
fi
if ! awk '
  /name: Retain staged installers for failed-build diagnosis/ { in_retain = 1 }
  in_retain && /if-no-files-found: error/ { found = 1; exit }
  in_retain && /^      - name:/ && !/Retain staged installers/ { exit }
  END { exit !found }
' "$workflow"; then
  echo 'diagnostic installer retention must keep the empty-path error gate' >&2
  exit 1
fi
if rg -n 'add-trusted-cert.*IRIS_SIGNING_P12|add-trusted-cert.*iris-signing\.p12' "$workflow"; then
  echo 'workflow must trust the public root, not the P12 leaf' >&2
  exit 1
fi

echo 'signing secrets and macOS ephemeral root trust are constrained correctly'
