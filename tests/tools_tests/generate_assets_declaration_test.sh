#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---


# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

generate_assets_declaration_sh_location=buildifier_prebuilt/tools/generate_assets_declaration.sh
generate_assets_declaration_sh="$(rlocation "${generate_assets_declaration_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_assets_declaration_sh_location}" && exit 1)


# MARK - Set Up a Workspace Directory

# Bazel sh_binary targets expect BUILD_WORKSPACE_DIRECTORY to exist. Because
# we are in a test, we need to fake it out.

repo_dir="${PWD}/repo"
rm -rf "${repo_dir}"
mkdir -p "${repo_dir}"
export "BUILD_WORKSPACE_DIRECTORY=${repo_dir}"


# MARK - Test with Defaults

actual="$( "${generate_assets_declaration_sh}" )"
assert_match "load.*@buildifier_prebuilt//:defs.bzl" "${actual}"
assert_match "buildifier_prebuilt_register_toolchains" "${actual}"
assert_match "buildifier_darwin_amd64" "${actual}"
assert_match "buildifier_linux_arm64" "${actual}"
assert_match "buildozer_linux_arm64" "${actual}"
assert_match "buildozer_darwin_amd64" "${actual}"


# MARK - Test with Release Tag

actual="$( "${generate_assets_declaration_sh}" "4.2.3" )"
assert_match "version.*4.2.3" "${actual}"
assert_match \
  "buildifier_darwin_amd64.*954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663" \
  "${actual}"
assert_match \
  "buildozer_darwin_arm64.*f8d0994620dec1247328f13db1d434b6489dd007f8e9b961dbd9363bc6fe7071" \
  "${actual}"


# MARK - Test Changing Defaults

actual="$( 
  "${generate_assets_declaration_sh}" \
    --reset_tools \
    --tool buildifier \
    --reset_platforms \
    --platform darwin \
    --reset_arches \
    --arch arm64 \
    "4.2.3" 
)"
assert_match "version.*4.2.3" "${actual}"
assert_match \
  "buildifier_darwin_arm64.*9434043897a3c3821fda87046918e5a6c4320d8352df700f62046744c4d168a3" \
  "${actual}"
