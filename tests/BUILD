load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":buildtools_tests.bzl", "buildtools_test_suite")

# A platform used for tests that must not match the host platform.
platform(
    name = "non_host_platform",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:riscv64",
    ],
)

build_test(
    name = "build_test",
    targets = [
        "//:defs",
        "//:deps",
        "//:rules",
        "//:buildtools",
    ],
)

buildtools_test_suite()
