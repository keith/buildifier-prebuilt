load("@cgrindel_bazel_starlib//tests:integration_test_common.bzl", "GH_ENV_INHERIT")

sh_test(
    name = "generate_assets_declaration_test",
    size = "medium",
    srcs = ["generate_assets_declaration_test.sh"],
    data = [
        "//tools:generate_assets_declaration",
    ],
    env_inherit = GH_ENV_INHERIT,
    deps = [
        "@bazel_tools//tools/bash/runfiles",
        "@cgrindel_bazel_starlib//shlib/lib:assertions",
    ],
)
