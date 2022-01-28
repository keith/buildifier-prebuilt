load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def buildifier_prebuilt_deps():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_starlib",
        sha256 = "fc2ee0fce914e3aee1a6af460d4ba1eed9d82e8125294d14e7d3f236d4a10a5d",
        strip_prefix = "bazel-starlib-0.3.2",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.3.2.tar.gz",
        ],
    )
