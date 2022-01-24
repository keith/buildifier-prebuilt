load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(
    "@buildifier_prebuilt//:rules.bzl",
    "buildifier_binary",
    "buildozer_binary",
)

exports_files(
    ["runner.bash.template"],
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain",
    visibility = ["//visibility:public"],
)

buildifier_binary(
    name = "buildifier",
    visibility = ["//visibility:public"],
)

buildozer_binary(
    name = "buildozer",
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "rules",
    srcs = ["rules.bzl"],
    deps = [
        "@bazel_skylib//lib:shell",
    ],
)

# MARK: - Integration Test

bzl_library(
    name = "bazel_versions",
    srcs = ["bazel_versions.bzl"],
)

filegroup(
    name = "local_repository_files",
    srcs = [
        "BUILD",
        "WORKSPACE",
        "defs.bzl",
        "rules.bzl",
        "runner.bash.template",
        "toolchain.bzl",
    ],
    visibility = ["//:__subpackages__"],
)

test_suite(
    name = "all_integration_tests",
    tags = [
        "exclusive",
        "manual",
    ],
    tests = [
        "//examples:integration_tests",
    ],
    visibility = ["//:__subpackages__"],
)
