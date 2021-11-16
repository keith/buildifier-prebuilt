"""
Binary buildifier / buildozer setup
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_VERSION = "4.2.3"
_BINARIES = [
    # platform, arch, buildifier sha, buildozer sha
    (
        "darwin",
        "amd64",
        "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663",
        "edcabae1d97bdc42559d7d1d65dfe7f8970db8d95d4bc9e7bf6656a9f2fb5592",
    ),
    (
        "darwin",
        "arm64",
        "9434043897a3c3821fda87046918e5a6c4320d8352df700f62046744c4d168a3",
        "f8d0994620dec1247328f13db1d434b6489dd007f8e9b961dbd9363bc6fe7071",
    ),
    (
        "linux",
        "amd64",
        "a19126536bae9a3917a7fc4bdbbf0378371a1d1683ab2415857cf53bce9dee49",
        "6b4177321b770fb788b618caa453d34561b8c05081ae8b27657e527c2a3b5d52",
    ),
]

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

def buildifier_prebuilt_deps():
    for platform, arch, buildifier_sha256, buildozer_sha256 in _BINARIES:
        http_file(
            name = "buildifier_{}_{}".format(platform, arch),
            urls = ["https://github.com/bazelbuild/buildtools/releases/download/{}/buildifier-{}-{}".format(_VERSION, platform, arch)],
            sha256 = buildifier_sha256,
            downloaded_file_path = "buildifier",
            executable = True,
        )
        http_file(
            name = "buildozer_{}_{}".format(platform, arch),
            urls = ["https://github.com/bazelbuild/buildtools/releases/download/{}/buildozer-{}-{}".format(_VERSION, platform, arch)],
            sha256 = buildozer_sha256,
            downloaded_file_path = "buildozer",
            executable = True,
        )

def buildifier_prebuilt_register_toolchains(
        name = "buildifier_prebuilt_toolchains"):
    _buildifier_toolchain_setup(name = name)
    native.register_toolchains(
        "@{}//:darwin_amd64_toolchain".format(name),
        "@{}//:darwin_arm64_toolchain".format(name),
        "@{}//:linux_amd64_toolchain".format(name),
    )
