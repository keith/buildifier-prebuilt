workspace(name = "buildifier_prebuilt")

load(":defs.bzl", "buildifier_prebuilt_deps", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_deps()

buildifier_prebuilt_register_toolchains()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

bazel_skylib_workspace()
