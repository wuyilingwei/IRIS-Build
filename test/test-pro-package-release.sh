#!/usr/bin/env bash
set -euo pipefail

workflow="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.github/workflows/build.yml"

ruby -r yaml -e '
  workflow = YAML.load_file(ARGV.fetch(0))
  jobs = workflow.fetch("jobs")
  expected_key = "${{ secrets.IRIS_PRO_PACKAGE_SIGNING_PUBLIC_KEY }}"
  private_secret = "${{ secrets.IRIS_PRO_PACKAGE_SIGNING_PRIVATE_KEY }}"

  def index_of(steps, name)
    index = steps.index { |step| step["name"] == name }
    raise "missing step: #{name}" unless index
    index
  end

  def assert_pro_step(steps, version, private_secret, expected_key)
    step = steps.select { |entry| entry["name"] == "Pack and upload private PRO package" }
    raise "expected one PRO package step" unless step.length == 1
    step = step.fetch(0)
    env = step.fetch("env")
    raise "incorrect PRO package id" unless env["IRIS_PRO_PACKAGE_ID"] == "iris.online-sync"
    raise "incorrect PRO package version" unless env["IRIS_PRO_PACKAGE_VERSION"] == version
    raise "incorrect minimum Core version" unless env["IRIS_PRO_PACKAGE_MIN_CORE_VERSION"] == version
    raise "missing private signing key" unless env["IRIS_PRO_PACKAGE_SIGNING_PRIVATE_KEY"] == private_secret
    raise "missing public signing key" unless env["IRIS_PRO_PACKAGE_SIGNING_PUBLIC_KEY"] == expected_key
    run = step.fetch("run")
    raise "PRO package key is not generated in this step" unless run.include?("randomBytes(32).toString(\"base64url\")")
    raise "PRO signing keys are not matched before upload" unless run.include?("createPublicKey") && run.include?("timingSafeEqual")
    raise "PRO package key is not cleared" unless run.include?("unset IRIS_PRO_PACKAGE_KEY")
    raise "PRO package artifact is not cleared" unless run.include?("rm -rf build/pro-packages/iris.online-sync")
    raise "missing PRO pack command" unless run.include?("npm run pro:pack")
    raise "missing private PRO upload command" unless run.include?("node .github/scripts/upload-pro-package.mjs")
    raise "package key must not cross jobs" if run.include?("GITHUB_OUTPUT") || run.include?("upload-artifact")
  end

  core_steps = jobs.fetch("core").fetch("steps")
  shell_check_steps = jobs.fetch("shell-check").fetch("steps")
  [core_steps, shell_check_steps].each do |steps|
    static = index_of(steps, "Run release static contract check")
    behavior = index_of(steps, "Run release behavior gate")
    raise "static contract check must run before behavior gate" unless static < behavior
    raise "static contract check must execute the static suite" unless steps.fetch(static).fetch("run").include?("npm run test:release-static")
    raise "behavior gate must remain the GUI behavior suite" unless steps.fetch(behavior).fetch("run").include?("npm run test:release-behavior")
  end
  assert_pro_step(core_steps, "${{ steps.number.outputs.core_version }}", private_secret, expected_key)
  assert_pro_step(shell_check_steps, "${{ steps.prepare.outputs.core_version }}", private_secret, expected_key)
  [[core_steps, "Generate core release key"], [shell_check_steps, "Generate release key"]].each do |steps, next_step|
    gate = index_of(steps, "Run release behavior gate")
    package = index_of(steps, "Pack and upload private PRO package")
    raise "PRO package step must follow behavior gate" unless package > gate
    raise "PRO package step must precede release material" unless package < index_of(steps, next_step)
  end

  shell_build = jobs.fetch("shell-build")
  shell_build_text = YAML.dump(shell_build)
  raise "Shell matrix must not publish or sign PRO packages" if shell_build_text.include?("IRIS_PRO_PACKAGE_SIGNING_PRIVATE_KEY") || shell_build_text.include?("npm run pro:pack") || shell_build_text.include?("upload-pro-package.mjs")
  installer = shell_build.fetch("steps").find { |step| step["name"] == "Build installer" }
  raise "Shell matrix is missing its installer build" unless installer
  raise "Shell matrix is missing shared PRO public key" unless installer.fetch("env")["IRIS_PRO_PACKAGE_SIGNING_PUBLIC_KEY"] == expected_key

  [
    jobs.fetch("core").fetch("steps").find { |step| step["name"] == "Pack core payload" },
    jobs.fetch("shell-check").fetch("steps").find { |step| step["name"] == "Decrypt and pack core payload" },
    installer,
  ].each do |step|
    raise "every Core payload and installer build must receive the same PRO public key" unless step.fetch("env")["IRIS_PRO_PACKAGE_SIGNING_PUBLIC_KEY"] == expected_key
  end

  [
    jobs.fetch("core").fetch("steps").find { |step| step["name"] == "Stage core release assets" },
    jobs.fetch("shell-release").fetch("steps").find { |step| step["name"] == "Mirror GitHub Release" },
  ].each do |step|
    raise "missing public release asset step" unless step
    text = YAML.dump(step)
    raise "public release may not include a PRO package artifact" if text.include?("build/pro-packages") || text.include?("manifest.json") || text.include?("artifact.irp")
  end
  puts "PRO package release constraints are satisfied"
' "$workflow"
