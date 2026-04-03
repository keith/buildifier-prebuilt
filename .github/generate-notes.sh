#!/bin/bash

set -euo pipefail

readonly new_version=$1
readonly archive=$2
sha256=$(shasum -a 256 "$archive" | cut -d ' ' -f 1)

cat <<EOF
### MODULE.bazel Snippet

\`\`\`bzl
bazel_dep(name = "buildifier_prebuilt", version = "$new_version", dev_dependency = True)
\`\`\`

### WORKSPACE Snippet

\`\`\`bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "$sha256",
    strip_prefix = "buildifier-prebuilt-$new_version",
    urls = [
        "http://github.com/keith/buildifier-prebuilt/archive/$new_version.tar.gz",
    ],
)

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()
\`\`\`
EOF
