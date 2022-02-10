"""
Toolchain setup boilerplate
"""

load("//:buildtools.bzl", "buildtools")

def _buildifier_toolchain(ctx):
    return [
        platform_common.ToolchainInfo(
            _tool = ctx.executable.tool,
        ),
    ]

prebuilt_toolchain = rule(
    _buildifier_toolchain,
    attrs = {
        "tool": attr.label(
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
            executable = True,
            doc = "Buildtools executable",
        ),
    },
    provides = [platform_common.ToolchainInfo],
)

def declare_toolchain(tool_name, tool, os, arch):  # buildifier: disable=unnamed-macro
    """Create the custom and native toolchain for a platform

    Args:
        tool_name: The tool the toolchain is being used for
        tool: The tool to use
        os: The OS the toolchain is compatible with
        arch: The arch the toolchain is compatible with
    """

    name = buildtools.create_unique_name(name = tool_name, platform = os, arch = arch)
    prebuilt_toolchain(
        name = name,
        tool = tool,
    )

    if os == "darwin":
        os = "macos"
    if arch == "amd64":
        arch = "x86_64"

    native.toolchain(
        name = name + "_toolchain",
        toolchain_type = "@buildifier_prebuilt//{tool}:toolchain".format(
            tool = tool_name,
        ),
        exec_compatible_with = [
            "@platforms//os:{}".format(os),
            "@platforms//cpu:{}".format(arch),
        ],
        toolchain = name,
    )
