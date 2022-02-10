"""
Simple rule for running buildozer from the toolchain config
"""

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
    attrs = {},
    toolchains = ["@buildifier_prebuilt//buildozer:toolchain"],
    executable = True,
)
