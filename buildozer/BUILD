load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(
    "@buildifier_prebuilt//:rules.bzl",
    "buildozer_binary",
)

bzl_library(
    name = "buildozer_binary",
    srcs = ["buildozer_binary.bzl"],
)

# Buildozer toolchain type
toolchain_type(
    name = "toolchain",
    visibility = ["//visibility:public"],
)

buildozer_binary(
    name = "buildozer",
    visibility = ["//visibility:public"],
)
