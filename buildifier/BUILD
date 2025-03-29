load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(
    ":buildifier_binary.bzl",
    "buildifier_binary",
    "buildifier_runner",
)

bzl_library(
    name = "buildifier_binary",
    srcs = ["buildifier_binary.bzl"],
)

# Buildifier toolchain type
toolchain_type(
    name = "toolchain",
    visibility = ["//visibility:public"],
)

buildifier_binary(
    name = "current_buildifier_binary",
    visibility = ["//visibility:public"],
)

alias(
    name = "buildifier",
    actual = ":current_buildifier_binary",
    visibility = ["//visibility:public"],
)

buildifier_runner(
    name = "current_buildifier_runner",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "all_files",
    srcs = glob(["*"]),
    visibility = ["//:__subpackages__"],
)
