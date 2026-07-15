load("@rules_shell//shell:sh_test.bzl", "sh_test")

sh_test(
    name = "binary_runner_test",
    srcs = ["binary_runner_test.sh"],
    args = [
        "$(location //:buildifier)",
        "$(location //:buildozer)",
    ],
    data = [
        "//:buildifier",
        "//:buildozer",
    ],
)
