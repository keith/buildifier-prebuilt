load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(
    ["runner.bash.template"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":buildtools",
    ],
)

bzl_library(
    name = "deps",
    srcs = ["deps.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "rules",
    srcs = ["rules.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@bazel_skylib//lib:shell",
    ],
)

bzl_library(
    name = "buildtools",
    srcs = ["buildtools.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@bazel_skylib//lib:new_sets",
        "@bazel_skylib//lib:types",
    ],
)

# MARK: - Aliases

alias(
    name = "buildifier",
    actual = "//buildifier",
    visibility = ["//visibility:public"],
)

alias(
    name = "buildozer",
    actual = "//buildozer",
    visibility = ["//visibility:public"],
)

# MARK: - Integration Test

bzl_library(
    name = "bazel_versions",
    srcs = ["bazel_versions.bzl"],
    visibility = ["//:__subpackages__"],
)

filegroup(
    name = "local_repository_files",
    srcs = [
        "BUILD",
        "WORKSPACE",
        "runner.bash.template",
        "//buildifier:all_files",
        "//buildozer:all_files",
    ] + glob(["*.bzl"]),
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
