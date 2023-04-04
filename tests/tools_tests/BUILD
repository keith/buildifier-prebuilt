sh_test(
    name = "generate_assets_declaration_test",
    size = "medium",
    srcs = ["generate_assets_declaration_test.sh"],
    data = [
        "//tools:generate_assets_declaration",
    ],
    env_inherit = [
        # The HOME, GH_TOKEN, and GITHUB_TOKEN environment variables help the gh utility find
        # its auth info.
        "GITHUB_TOKEN",
        "GH_TOKEN",
        "HOME",
    ],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
        "@cgrindel_bazel_starlib//shlib/lib:assertions",
    ],
)
