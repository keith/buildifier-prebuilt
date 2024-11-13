load("@buildifier_prebuilt//:rules.bzl", "buildifier", "buildifier_test")

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

sh_test(
    name = "version_test",
    srcs = ["version_test.sh"],
    args = [
        "$(location @buildifier_prebuilt//:buildozer)",
    ],
    data = [
        "@buildifier_prebuilt//:buildozer",
    ],
)
