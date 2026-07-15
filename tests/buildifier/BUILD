load("@rules_shell//shell:sh_test.bzl", "sh_test")

sh_test(
    name = "buildifier_test",
    size = "medium",
    srcs = ["buildifier_test.sh"],
    data = [
        "//:WORKSPACE",
        "//tests/unittest",
        "@bazel_tools//tools/bash/runfiles",
        "@buildifier_prebuilt//buildifier",
    ],
    tags = ["local"],
)
