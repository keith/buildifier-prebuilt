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
    attrs = {},
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
    executable = True,
)
