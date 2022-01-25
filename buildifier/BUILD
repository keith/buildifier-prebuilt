load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(
    "@buildifier_prebuilt//:rules.bzl",
    "buildifier_binary",
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
    name = "buildifier",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "all_files",
    srcs = glob(["*"]),
    visibility = ["//:__subpackages__"],
)
