workspace(name = "buildifier_prebuilt")

load(":deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load(":defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - Test and Release Dependencies

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "52102a2022624a18587ec32ecf12cf174b5fbf06d97f9787597cd3f1aca4cd0d",
    urls = [
        "https://github.com/cgrindel/bazel-starlib/releases/download/v0.15.0/bazel-starlib.v0.15.0.tar.gz",
    ],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

http_archive(
    name = "rules_bazel_integration_test",
    sha256 = "0a1edb5ceb2797e463d40c0ae1c1b0de2c12104304ce07930a43ba4c9a314f85",
    urls = [
        "https://github.com/bazel-contrib/rules_bazel_integration_test/releases/download/v0.12.0/rules_bazel_integration_test.v0.12.0.tar.gz",
    ],
)

load("@rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")

bazel_binaries(versions = [
    "//:.bazelversion",
    "5.4.0",
])
