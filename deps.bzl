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

    # TODO: FIX ME

    maybe(
        native.local_repository,
        name = "cgrindel_bazel_starlib",
        path = "/Users/chuck/code/cgrindel/bazel-starlib",
    )

#     maybe(
#         http_archive,
#         name = "cgrindel_bazel_starlib",
#         sha256 = "9e054e423bb7674e02052e52725b41288369dd94efff963479f76fe269b5177f",
#         strip_prefix = "bazel-starlib-0.3.1",
#         urls = [
#             "http://github.com/cgrindel/bazel-starlib/archive/v0.3.1.tar.gz",
#         ],
#     )
