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

hello_world_sh_location=simple_example/hello_world.sh
hello_world_sh="$(rlocation "${hello_world_sh_location}")" || \
  (echo >&2 "Failed to locate ${hello_world_sh_location}" && exit 1)


# MARK - Test

actual="$( "${hello_world_sh}" )"
[[ "${actual}" == "Hello, World!" ]] || (echo >&2 "Expected default greeting. ${actual}"; exit 1)

actual="$( "${hello_world_sh}" "John" )"
[[ "${actual}" == "Hello, John!" ]] || (echo >&2 "Expected greeting for John. ${actual}"; exit 1)
