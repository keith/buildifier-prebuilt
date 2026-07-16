#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# return a unix-style path on all platforms
# workaround for https://github.com/bazelbuild/bazel/issues/22803
function rlocation_as_unix() {
  path=$(rlocation "${1}")
  case "$(uname -s)" in
  CYGWIN* | MINGW32* | MSYS* | MINGW*)
    path=${path//\\//} # backslashes to forward
    path=/${path//:/}  # d:/ to /d/
    ;;
  esac
  echo "$path"
}

# MARK - Locate Deps

unittest_bash_location=_main/tests/unittest/unittest.bash
unittest_bash="$(rlocation_as_unix "${unittest_bash_location}")"
source ${unittest_bash} || exit 1

# MARK - Setup Workspace

# Global variable
__wsdir=0

function create_bazelrc() {
    wsdir=$1
    cat >"${wsdir}/.bazelrc" << EOF
common --enable_bzlmod
common --noenable_workspace
startup --windows_enable_symlinks
common --noshow_progress
EOF
}

function create_workspace_file() {
    wsdir=$1
    buildifier_dir=$2
    cat >"${wsdir}/WORKSPACE" << EOF
workspace(name = "simple_example")
local_repository(
    name = "buildifier_prebuilt",
    path = "$buildifier_dir",
)
load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")
buildifier_prebuilt_deps()
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()
load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")
buildifier_prebuilt_register_toolchains()
EOF
}

function create_module_file() {
    wsdir=$1
    buildifier_dir=$2
    cat >"${wsdir}/MODULE.bazel" << EOF
module(name = "simple_example")
bazel_dep(name = "buildifier_prebuilt", version = "0.0.0")
local_path_override(
    module_name = "buildifier_prebuilt",
    path = "$buildifier_dir",
)
EOF
}

function create_build_file() {
    dest=$1
    cat >"$dest" << EOF


load("@buildifier_prebuilt//:rules.bzl", "buildifier", "buildifier_test")

buildifier(

    name = "buildifier.check",
    exclude_patterns = ["./.git/*"],
    lint_mode = "warn",
    lint_warnings = [

"-cc-native"
],
    mode = "diff",
)

buildifier(
    name = "buildifier.fix",
    exclude_patterns = ["./.git/*"],
    lint_mode = "fix",
    lint_warnings = ["-cc-native"],
    mode = "fix",
)

buildifier_test(
    name = "buildifier.test",
    srcs = [      "BUILD"      ],
    lint_mode = "warn",
)

buildifier_test(
    name = "buildifier.test.workspace",
    srcs = ["BUILD"],
    lint_mode = "warn",
    no_sandbox = True,
    workspace = "WORKSPACE",
)
EOF
}

function create_batch_sensitive_package() {
    mkdir -p "pkg dir (batch)"
    cat >"pkg dir (batch)/BUILD" << EOF
filegroup(
    name = "batch_sensitive_path",
)
EOF
}

function create_simple_workspace() {
    buildifier_dir=$(parent_source_dir)
    __wsdir=${1:-testws_${RANDOM}}

    echo create_simple_workspace in "$(pwd)/${__wsdir}"
    echo new workspace references buildifier module in "$buildifier_dir"
    mkdir -p "${__wsdir}"

    create_bazelrc "${__wsdir}"
    create_module_file "${__wsdir}" "$buildifier_dir"
    create_workspace_file "${__wsdir}" "$buildifier_dir"
    create_build_file "${__wsdir}/BUILD"
    cd "${__wsdir}"
}

function tear_down() {
    bazel shutdown >>"${TEST_log}" 2>&1
    cd ..
    rm -rf "${__wsdir}"
}

# MARK - Test Utilities

function native_path() {
    path=$1
    case "$(uname -s)" in
    CYGWIN* | MINGW32* | MSYS* | MINGW*)
        path=$(cygpath -C ANSI -w -p "$path")
        path=${path//\\//}
        ;;
    esac
    echo "$path"
}

function is_windows() {
    case "$(uname -s)" in
    CYGWIN* | MINGW32* | MSYS* | MINGW*)
        return 0
        ;;
    esac
    return 1
}

function parent_source_dir() {
    # this gives the source workspace in norunfiles mode (read MANIFEST)
    parent_ws1=$(dirname "$(rlocation "_main/WORKSPACE")")
    if [[ ! -f WORKSPACE ]]; then
        echo "$parent_ws1"
        return
    fi
    # this gives the source workspace in runfiles mode (follow symlink)
    parent_ws2=$(dirname "$(native_path "$(realpath WORKSPACE)")")
    # pick the shorter result. Is there a canonical way to do this?
    if [[ ${#parent_ws1} -lt ${#parent_ws2} ]]; then
        parent_dir=$parent_ws1
    else
        parent_dir=$parent_ws2
    fi
    echo "$parent_dir"
}

function issue_in_file() {
    filename=$1
    # output is different on windows (Comparing files WORKSPACE and ...)
    # and unix (--- ./WORKSPACE). Some Windows diff implementations omit the
    # subsequent ***** WORKSPACE header, so use the line they all emit.
    if is_windows; then
        echo "^Comparing files ${filename} and .*$"
    else
        echo "^--- ./${filename}"
    fi
    return
}

# MARK - Test Cases

function expect_buildifier_check_failure() {
    local runfiles_flag=$1
    local exit_code=0

    bazel run \
        "${runfiles_flag}" \
        //:buildifier.check >>"${TEST_log}" 2>&1 || exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        fail "check exited successfully despite intentional formatting issues"
    fi

    expect_log "Build completed successfully" "Bazel failed before running buildifier"
    expect_log "Running command line: bazel-bin/buildifier\.check" "Bazel did not run buildifier"
    expect_not_log "^ERROR:" "unexpected Bazel error while running buildifier"
    expect_log "$(issue_in_file MODULE.bazel)" "deliberate buildifier issue in MODULE.bazel not found"
    expect_log "$(issue_in_file BUILD)" "deliberate buildifier issue in BUILD not found"
    expect_log "$(issue_in_file WORKSPACE)" "deliberate buildifier issue in WORKSPACE not found"
}

function assert_fix_changed_files() {
    local grep_exit_code=0
    local diff_exit_code=0

    grep -xq "$(issue_in_file WORKSPACE)" "${TEST_log}" || grep_exit_code=$?
    if [[ ${grep_exit_code} -eq 0 ]]; then
        fail "deliberate buildifier issue in WORKSPACE should have been fixed but it still exists"
    elif [[ ${grep_exit_code} -ne 1 ]]; then
        fail "grep failed with code ${grep_exit_code} while checking buildifier output"
    fi

    diff orig-BUILD-file BUILD >>"${TEST_log}" || diff_exit_code=$?
    if [[ ${diff_exit_code} -eq 0 ]]; then
        fail "Expected BUILD to have changed from original"
    elif [[ ${diff_exit_code} -ne 1 ]]; then
        fail "diff failed with code ${diff_exit_code} while checking formatted BUILD"
    fi
}

function test_buildifier_test_rejects_unformatted_build() {
    local exit_code=0

    create_simple_workspace >"${TEST_log}"

    env -u BUILD_WORKSPACE_DIRECTORY bazel test \
        --enable_runfiles \
        --test_output=errors \
        //:buildifier.test >>"${TEST_log}" 2>&1 || exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        fail "buildifier.test passed despite intentional formatting issues"
    fi

    expect_log "//:buildifier\.test.*FAILED" "buildifier.test did not report a test failure"
    expect_log "$(issue_in_file BUILD)" "deliberate buildifier issue in BUILD not found"
}

function test_buildifier_check_with_runfiles() {
    create_simple_workspace >"${TEST_log}"

    expect_buildifier_check_failure --enable_runfiles
}

function test_buildifier_check_without_runfiles() {
    create_simple_workspace >"${TEST_log}"

    expect_buildifier_check_failure --noenable_runfiles
}

function test_buildifier_fix_with_runfiles() {
    create_simple_workspace >"${TEST_log}"
    cp BUILD orig-BUILD-file

    bazel run --enable_runfiles //:buildifier.fix >>"${TEST_log}" 2>&1 || fail "fix exited with non-zero code but should have succeeded"
    bazel run --enable_runfiles //:buildifier.check >>"${TEST_log}" 2>&1 || fail "check exited with non-zero code but should have succeeded"

    expect_log "Running command line: bazel-bin/buildifier\.check"
    assert_fix_changed_files
}

function test_buildifier_fix_without_runfiles() {
    create_simple_workspace >"${TEST_log}"
    cp BUILD orig-BUILD-file

    bazel run --noenable_runfiles //:buildifier.fix >>"${TEST_log}" 2>&1 || fail "fix exited with non-zero code but should have succeeded"
    bazel run --noenable_runfiles //:buildifier.check >>"${TEST_log}" 2>&1 || fail "check exited with non-zero code but should have succeeded"

    expect_log "Running command line: bazel-bin/buildifier\.check"
    assert_fix_changed_files
}

function test_buildifier_fix_windows_batch_sensitive_paths() {
    if ! is_windows; then
        echo "SKIPPED windows batch path regression"
        return 0
    fi

    create_simple_workspace "test ws (batch) ${RANDOM}" >"${TEST_log}"
    create_batch_sensitive_package

    for runfiles_flag in --enable_runfiles --noenable_runfiles; do
        bazel run "${runfiles_flag}" //:buildifier.fix >>"${TEST_log}" 2>&1 || fail "fix exited with non-zero code for ${runfiles_flag}"
        bazel run "${runfiles_flag}" //:buildifier.check >>"${TEST_log}" 2>&1 || fail "check exited with non-zero code for ${runfiles_flag}"
    done

    expect_not_log "was unexpected at this time" "batch parser failed on a workspace or file path"
    expect_not_log "Unable to change working directory" "batch runner failed to cd to the workspace"
}

run_suite "buildifier suite"
