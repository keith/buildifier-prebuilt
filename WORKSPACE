workspace(name = "buildifier_prebuilt")

load(":deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load(":defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - Test and Release Dependencies

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "fc2ee0fce914e3aee1a6af460d4ba1eed9d82e8125294d14e7d3f236d4a10a5d",
    strip_prefix = "bazel-starlib-0.3.2",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/v0.3.2.tar.gz",
    ],
)

http_archive(
    name = "cgrindel_rules_bazel_integration_test",
    sha256 = "39071d2ec8e3be74c8c4a6c395247182b987cdb78d3a3955b39e343ece624982",
    strip_prefix = "rules_bazel_integration_test-0.5.0",
    urls = [
        "http://github.com/cgrindel/rules_bazel_integration_test/archive/v0.5.0.tar.gz",
    ],
)

load("@cgrindel_rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")
load("@cgrindel_rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
