#!/usr/bin/env bash
set -euo pipefail

workflow="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.github/workflows/build.yml"

if rg -n 'IRIS_MACOS_SIGNING_P12_BASE64|IRIS_MACOS_SIGNING_PASSWORD|IRIS_LEGACY|IRIS_SIGNING_MIGRATION_PHASE|IRIS_SIGNING_PROFILE|8601bb53dfc44d12d26f0e513ced84673b874cea|iris-internal-signing-root\.cert\.pem|secrets\.IRIS_SIGNING_P12_BASE64|secrets\.IRIS_SIGNING_PASSWORD' "$workflow"; then
  echo 'workflow must use only the unified retained signing identity' >&2
  exit 1
fi

rg -q 'name: Restore signing certificate from source history' "$workflow"
rg -q '95b59114f2c3a5972799512155ec12978324ab0b' "$workflow"
rg -q 'iris-internal-signing-100y\.key\.pem' "$workflow"
rg -q 'openssl pkcs12 -export' "$workflow"
rg -q 'openssl pkcs12 -export -legacy' "$workflow"
rg -q 'IRIS_SIGNING_ROOT_SHA1: 7dbbec289bce316a2163ee3d4f4292836733bd78' "$workflow"
rg -q 'IRIS_SIGNING_ROOT_PATH: certificates/iris-internal-signing-100y\.cert\.pem' "$workflow"
rg -q 'name: Restore signing certificate from source history' "$workflow"
rg -q 'name: Verify signing identity' "$workflow"
rg -q 'name: Trust signing root for macOS build' "$workflow"
rg -q 'name: Remove signing root' "$workflow"
rg -q 'sudo -n /usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain' "$workflow"
rg -q 'sudo -n /usr/bin/security delete-certificate -Z "\$IRIS_SIGNING_ROOT_SHA1" /Library/Keychains/System.keychain' "$workflow"
rg -q "if: always\(\) && matrix.os == 'macos-latest'" "$workflow"
test "$(rg -c '/usr/bin/perl -e' "$workflow")" -eq 2
rg -q 'name: Retain staged installers for failed-build diagnosis' "$workflow"
rg -q "if: always\(\) && hashFiles\('staged-installers/\*\*'\) != ''" "$workflow"

ruby -r yaml -e '
  workflow = YAML.load_file(ARGV.fetch(0))
  jobs = workflow.fetch("jobs")

  def index_of(steps, name)
    index = steps.index { |step| step["name"] == name }
    raise "missing step: #{name}" unless index
    index
  end

  shell_check = jobs.fetch("shell-check")
  validation = shell_check.fetch("steps").find { |step| step["name"] == "Validate inputs and secrets" }
  raise "shell-check signing validation is missing" unless validation
  env = validation.fetch("env")
  raise "shell-check must not read a signing secret" if env.key?("IRIS_SIGNING_CERT_BASE64") || env.key?("IRIS_SIGNING_CERT_PASSWORD")
  run = validation.fetch("run")
  raise "shell-check no longer validates the release upload token" unless run.include?("IRIS_RELEASE_UPLOAD_TOKEN")

  build_steps = jobs.fetch("shell-build").fetch("steps")
  prepare = index_of(build_steps, "Restore signing certificate from source history")
  verify = index_of(build_steps, "Verify signing identity")
  trust = index_of(build_steps, "Trust signing root for macOS build")
  windows_trust = index_of(build_steps, "Trust signing root for Windows build")
  installer = index_of(build_steps, "Build installer")
  cleanup = index_of(build_steps, "Remove signing root")
  windows_cleanup = index_of(build_steps, "Remove signing root from Windows build")
  raise "signing certificate must be prepared before verification" unless prepare < verify
  raise "macOS root must be trusted before installer build" unless trust < installer
  raise "Windows root must be trusted before installer build" unless windows_trust < installer
  raise "macOS root cleanup must follow installer build" unless installer < cleanup
  raise "Windows root cleanup must follow installer build" unless installer < windows_cleanup
  prepare_run = build_steps.fetch(prepare).fetch("run")
  raise "historical key is not restored" unless prepare_run.include?("iris-internal-signing-100y.key.pem")
  raise "restored signing material is not exported as P12" unless prepare_run.include?("openssl pkcs12 -export")
  raise "restored signing material is not compatible with macOS Keychain" unless prepare_run.include?("openssl pkcs12 -export -legacy")
  windows_trust_run = build_steps.fetch(windows_trust).fetch("run")
  raise "Windows root is not installed before verification" unless windows_trust_run.include?("certutil.exe -addstore -f Root")
  installer_run = build_steps.fetch(installer).fetch("run")
  raise "installer does not receive the restored P12 password" unless installer_run.include?("CSC_KEY_PASSWORD=\"$IRIS_SIGNING_CERT_PASSWORD\"")
  installer_verification = index_of(build_steps, "Verify signed installers")
  retain = index_of(build_steps, "Retain staged installers for failed-build diagnosis")
  raise "diagnostic installer retention must follow signature verification" unless installer_verification < retain
  retain_step = build_steps.fetch(retain)
  raise "diagnostic installer retention must keep the empty-path error gate" unless retain_step.fetch("with")["if-no-files-found"] == "error"

  release = jobs.fetch("shell-release")
  raise "shell release must require shell-check and shell-build" unless release.fetch("needs") == ["shell-check", "shell-build"]
  release_steps = release.fetch("steps")
  publish = index_of(release_steps, "Publish to license service")
  tags = index_of(release_steps, "Tag published shell and core source")
  mirror = index_of(release_steps, "Mirror GitHub Release")
  raise "release ordering is not atomic" unless publish < tags && tags < mirror
  publish_run = release_steps.fetch(publish).fetch("run")
  payload = publish_run.index("upload-payload with-key")
  assets = publish_run.index("publish-shell-assets")
  raise "payload must publish before shell assets" unless payload && assets && payload < assets
' "$workflow"

if rg -n 'add-trusted-cert.*IRIS_SIGNING_P12|add-trusted-cert.*iris-signing\.p12' "$workflow"; then
  echo 'workflow must trust the tracked public certificate, not the P12 leaf' >&2
  exit 1
fi

echo 'unified signing identity and release ordering are constrained correctly'
