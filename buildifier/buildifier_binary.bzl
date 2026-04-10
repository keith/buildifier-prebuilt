"""
Simple rule for running buildifier from the toolchain config
"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

def _buildifier_binary(ctx):
    buildifier = ctx.toolchains["@buildifier_prebuilt//buildifier:toolchain"]._tool
    script = ctx.actions.declare_file("buildifier")
    ctx.actions.symlink(
        output = script,
        target_file = buildifier,
        is_executable = True,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(files = [buildifier]),
            executable = script,
        ),
    ]

buildifier_binary = rule(
    implementation = _buildifier_binary,
    exec_compatible_with = [] if bazel_features.toolchains.has_default_test_toolchain_type else HOST_CONSTRAINTS,
    toolchains = [
        "@buildifier_prebuilt//buildifier:toolchain",
    ] + ([
        "@bazel_tools//tools/test:default_test_toolchain_type",
    ] if bazel_features.toolchains.has_default_test_toolchain_type else []),
    executable = True,
)
