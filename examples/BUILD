load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")
load(
    "@cgrindel_rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_tests",
    "default_test_runner",
    "integration_test_utils",
)

default_test_runner(
    name = "simple_test_runner",
    bazel_cmds = [
        "info",
        "run //:buildifier.check",
        "test //...",
    ],
)

bazel_integration_tests(
    name = "simple_test",
    bazel_versions = SUPPORTED_BAZEL_VERSIONS,
    test_runner = ":simple_test_runner",
    workspace_files = integration_test_utils.glob_workspace_files("simple") + [
        "//:local_repository_files",
    ],
    workspace_path = "simple",
)

test_suite(
    name = "integration_tests",
    # If you don't apply the test tags to the test suite, the test suite will
    # be found when `bazel test //...` is executed.
    tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS,
    tests = integration_test_utils.bazel_integration_test_names(
        "simple_test",
        SUPPORTED_BAZEL_VERSIONS,
    ),
    visibility = ["//:__subpackages__"],
)
