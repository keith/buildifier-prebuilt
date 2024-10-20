load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(
    ["runner.bash.template", "runner.bat.template", "WORKSPACE"],
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

filegroup(
    name = "local_repository_files",
    srcs = [
        "BUILD",
        "MODULE.bazel",
        "WORKSPACE",
        "runner.bash.template",
        "runner.bat.template",
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
