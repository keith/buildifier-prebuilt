"""
Simple rule for providing buildifier fro the target platform from the toolchain config
"""

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
    doc = "Expose the current target platform's buildifier binary",
    implementation = _buildifier_binary,
    attrs = {},
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
    executable = True,
)

def _buildifier_runner(ctx):
    return DefaultInfo(
        files = ctx.toolchains["@buildifier_prebuilt//buildifier:toolchain"]._runner.files,
    )

buildifier_runner = rule(
    doc = "Expose the current target platform's buildifier runner template",
    implementation = _buildifier_runner,
    attrs = {},
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
)
