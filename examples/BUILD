load("@bazel_binaries//:defs.bzl", "bazel_binaries")
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")
load(
    "@rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_tests",
    "default_test_runner",
    "integration_test_utils",
)

# Add test for buildozer

default_test_runner(
    name = "default_test_runner",
    bazel_cmds = [
        "info",
        "run //:buildifier.check",
        "test //...",
    ],
)

sh_binary(
    name = "modify_example_test_runner",
    testonly = True,
    srcs = ["modify_example_test_runner.sh"],
    data = [
        "@rules_bazel_integration_test//tools:create_scratch_dir",
    ],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
        "@cgrindel_bazel_starlib//shlib/lib:assertions",
    ],
)

_ALL_EXAMPLES = [
    "bzlmod",
    "bzlmod_specify_assets",
    "simple",
    "specify_assets",
]

_EXAMPLE_RUNNERS = {
    "bzlmod": ":modify_example_test_runner",
    "simple": ":modify_example_test_runner",
}

_EXAMPLE_BAZEL_VERSIONS = {
    "bzlmod": [bazel_binaries.versions.current],
    "bzlmod_specify_assets": [bazel_binaries.versions.current],
}

[
    bazel_integration_tests(
        name = "{}_test".format(example),
        bazel_binaries = bazel_binaries,
        bazel_versions = _EXAMPLE_BAZEL_VERSIONS.get(
            example,
            bazel_binaries.versions.all,
        ),
        test_runner = _EXAMPLE_RUNNERS.get(example, ":default_test_runner"),
        workspace_files = integration_test_utils.glob_workspace_files(example) + [
            "//:local_repository_files",
        ],
        workspace_path = example,
    )
    for example in _ALL_EXAMPLES
]

test_suite(
    name = "integration_tests",
    # If you don't apply the test tags to the test suite, the test suite will
    # be found when `bazel test //...` is executed.
    tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
    tests = lists.flatten([
        integration_test_utils.bazel_integration_test_names(
            "{}_test".format(example),
            _EXAMPLE_BAZEL_VERSIONS.get(
                example,
                bazel_binaries.versions.all,
            ),
        )
        for example in _ALL_EXAMPLES
    ]),
    visibility = ["//:__subpackages__"],
)
