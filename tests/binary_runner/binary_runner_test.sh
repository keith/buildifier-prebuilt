#!/usr/bin/env bash

set -euo pipefail

buildifier=$(realpath "$1")
buildozer=$(realpath "$2")
workspace="${TEST_TMPDIR}/workspace"
working_directory="${workspace}/pkg"
decoy="${TEST_TMPDIR}/decoy"

mkdir -p "$working_directory" "$decoy"

cat >"${workspace}/MODULE.bazel" <<'EOF'
module(name = "binary_runner_test")
EOF

cat >"${workspace}/BUILD" <<'EOF'
filegroup(
    name = "workspace_target",
)
EOF

cat >"${working_directory}/BUILD" <<'EOF'
filegroup(
    name = "working_target",
)
EOF

cat >"${working_directory}/working_only.bzl" <<'EOF'
WORKING_ONLY = True
EOF

# A workspace marker here makes a raw buildtools binary treat this directory as
# the workspace root. The runner must instead use the Bazel working-directory
# environment variables.
touch "${decoy}/MODULE.bazel"
cd "$decoy"

case "$(uname -s)" in
CYGWIN* | MINGW32* | MSYS* | MINGW*)
  BUILD_WORKSPACE_DIRECTORY=$(cygpath -w "$workspace")
  BUILD_WORKING_DIRECTORY=$(cygpath -w "$working_directory")
  ;;
*)
  BUILD_WORKSPACE_DIRECTORY=$workspace
  BUILD_WORKING_DIRECTORY=$working_directory
  ;;
esac
export BUILD_WORKING_DIRECTORY BUILD_WORKSPACE_DIRECTORY

# BUILD_WORKING_DIRECTORY takes precedence over BUILD_WORKSPACE_DIRECTORY.
"$buildifier" -mode=check working_only.bzl

output=$("$buildozer" 'print name' :all)
if [[ "$output" != "working_target" ]]; then
  echo "Unexpected buildozer output from working directory: $output" >&2
  exit 1
fi

# BUILD_WORKSPACE_DIRECTORY is used when BUILD_WORKING_DIRECTORY is absent.
unset BUILD_WORKING_DIRECTORY
"$buildifier" -mode=check BUILD

output=$("$buildozer" 'print name' //:all)
if [[ "$output" != "workspace_target" ]]; then
  echo "Unexpected buildozer output from workspace directory: $output" >&2
  exit 1
fi
