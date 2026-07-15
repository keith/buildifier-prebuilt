"""
Simple rule for running buildifier from the toolchain config
"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

def _buildifier_binary(ctx):
    toolchain = ctx.toolchains["@buildifier_prebuilt//buildifier:toolchain"]
    buildifier = toolchain._tool
    runner = toolchain._binary_runner
    out_ext = ".bash" if runner.label.name.endswith(".bash.template") else ".bat"
    script = ctx.actions.declare_file(ctx.label.name + out_ext)
    ctx.actions.expand_template(
        template = runner.files.to_list()[0],
        output = script,
        substitutions = {
            "{TOOL_NAME}": "buildifier",
            "{TOOL_FILENAME}": buildifier.basename,
            "{TOOL_SHORT_PATH}": buildifier.short_path,
        },
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
