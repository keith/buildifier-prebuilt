load("@buildifier_prebuilt//:rules.bzl", "buildifier", "buildifier_test")

buildifier(
    name = "buildifier.check",
    exclude_patterns = [
        "./.git/*",
    ],
    lint_mode = "warn",
    lint_warnings = [
        "-cc-native",
    ],
    mode = "diff",
)

buildifier_test(
    name = "buildifier.test",
    srcs = ["BUILD"],
    lint_mode = "warn",
)

sh_binary(
    name = "hello_world",
    srcs = ["hello_world.sh"],
)

sh_test(
    name = "hello_world_test",
    srcs = ["hello_world_test.sh"],
    data = [
        ":hello_world",
    ],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
    ],
)
