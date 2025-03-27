load("@buildifier_prebuilt//:rules.bzl", "buildifier", "buildifier_test")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

buildifier(
    name = "buildifier.check",
    disabled_rewrites = [
        "label",
    ],
    exclude_patterns = [
        "./.git/*",
    ],
    lint_mode = "warn",
)

buildifier_test(
    name = "buildifier.test",
    srcs = glob(["**/BUILD"]),
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
