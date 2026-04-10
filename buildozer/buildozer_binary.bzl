"""
Simple rule for running buildozer from the toolchain config
"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

_TEST_TOOLCHAIN = bazel_features.toolchains.has_default_test_toolchain_type

def _buildozer_binary(ctx):
    buildozer = ctx.toolchains["@buildifier_prebuilt//buildozer:toolchain"]._tool
    script = ctx.actions.declare_file("buildozer")
    ctx.actions.symlink(
        output = script,
        target_file = buildozer,
        is_executable = True,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(files = [buildozer]),
            executable = script,
        ),
    ]

buildozer_binary = rule(
    implementation = _buildozer_binary,
    exec_compatible_with = [] if _TEST_TOOLCHAIN else HOST_CONSTRAINTS,
    toolchains = [
        "@buildifier_prebuilt//buildozer:toolchain",
    ] + ([
        "@bazel_tools//tools/test:default_test_toolchain_type",
    ] if _TEST_TOOLCHAIN else []),
    executable = True,
)
