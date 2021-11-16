"""
Toolchain setup boilerplate
"""

def _buildifier_toolchain(ctx):
    return [
        platform_common.ToolchainInfo(
            _buildifier = ctx.executable.buildifier,
            _buildozer = ctx.executable.buildozer,
        ),
    ]

buildifier_toolchain = rule(
    _buildifier_toolchain,
    attrs = {
        "buildifier": attr.label(
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
            executable = True,
            doc = "Buildifier executable",
        ),
        "buildozer": attr.label(
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
            executable = True,
            doc = "Buildozer executable",
        ),
    },
    provides = [platform_common.ToolchainInfo],
)

def declare_toolchain(name, buildifier, buildozer, os, arch):
    """Create the custom and native toolchain for a platform

    Args:
        name: The name of the underlying toolchain
        buildifier: The buildifier binary for the platform / arch
        buildozer: The buildozer binary for the platform / arch
        os: The OS the toolchain is compatible with
        arch: The arch the toolchain is compatible with
    """
    buildifier_toolchain(
        name = name,
        buildifier = buildifier,
        buildozer = buildozer,
    )

    if os == "darwin":
        os = "macos"
    if arch == "amd64":
        arch = "x86_64"

    native.toolchain(
        name = name + "_toolchain",
        toolchain_type = "@buildifier_prebuilt//:toolchain",
        exec_compatible_with = [
            "@platforms//os:{}".format(os),
            "@platforms//cpu:{}".format(arch),
        ],
        toolchain = name,
    )
