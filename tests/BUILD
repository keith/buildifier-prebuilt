load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":buildtools_tests.bzl", "buildtools_test_suite")

build_test(
    name = "build_test",
    targets = [
        "//:defs",
        "//:deps",
        "//:rules",
        "//:buildtools",
        "//:bazel_versions",
    ],
)

buildtools_test_suite()
