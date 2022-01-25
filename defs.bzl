"""
Binary buildifier / buildozer setup
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//:buildtools.bzl", "buildtools")

def _buildifier_toolchain_setup_impl(repository_ctx):
    content = 'load("@buildifier_prebuilt//:toolchain.bzl", "declare_toolchain")'

    for platform, arch, _, _ in _BINARIES:
        name = "{}_{}".format(platform, arch)
        content += """
declare_toolchain(
    name = "{name}",
    buildifier = "@buildifier_{platform}_{arch}//file:buildifier",
    buildozer = "@buildozer_{platform}_{arch}//file:buildozer",
    os = "{platform}",
    arch = "{arch}",
)

""".format(name = name, platform = platform, arch = arch)
    repository_ctx.file("BUILD.bazel", content)

_buildifier_toolchain_setup = repository_rule(
    implementation = _buildifier_toolchain_setup_impl,
)

def buildifier_prebuilt_deps(assets = buildtools.DEFAULT_ASSETS):
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    if len(assets) == 0:
        fail("No assets were specified.")

    for asset in assets:
        http_file_args = {
            "name": "{name}_{platform}_{arch}".format(
                name = asset.name,
                platform = asset.platform,
                arch = asset.arch,
            ),
            "urls": [
                "https://github.com/bazelbuild/buildtools/releases/download/{version}/{name}-{platform}-{arch}".format(
                    version = asset.version,
                    name = asset.name,
                    platform = asset.platform,
                    arch = asset.arch,
                ),
            ],
            "downloaded_file_path": asset.name,
            "executable": True,
        }
        if asset.sha256:
            http_file_args["sha256"] = asset.sha256
        http_file(**http_file_args)

def buildifier_prebuilt_register_toolchains(
        name = "buildifier_prebuilt_toolchains"):
    _buildifier_toolchain_setup(name = name)
    native.register_toolchains(
        "@{}//:darwin_amd64_toolchain".format(name),
        "@{}//:darwin_arm64_toolchain".format(name),
        "@{}//:linux_amd64_toolchain".format(name),
    )
