sh_test(
    name = "buildifier_test",
    srcs = ["buildifier_test.sh"],
    size = "medium",
    data = [
        "//tests/unittest",
        "@bazel_tools//tools/bash/runfiles",
        "//:WORKSPACE",
        "@buildifier_prebuilt//buildifier",
    ],
    tags = ["local"],
)
