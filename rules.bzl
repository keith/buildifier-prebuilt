"""
Rules to use the prebuilt buildifier / buildozer binaries
"""

def _buildifier_binary(ctx):
    buildifier = ctx.toolchains["@buildifier_prebuilt//:toolchain"]._buildifier
    script = ctx.actions.declare_file("buildifier.sh")
    ctx.actions.write(
        script,
        """\
#!/usr/bin/env bash

exec {buildifier} "$@"
""".format(buildifier = buildifier.short_path),
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
    toolchains = ["@buildifier_prebuilt//:toolchain"],
    executable = True,
)

def _buildozer_binary(ctx):
    buildozer = ctx.toolchains["@buildifier_prebuilt//:toolchain"]._buildozer
    script = ctx.actions.declare_file("buildozer.sh")
    ctx.actions.write(
        script,
        """\
#!/usr/bin/env bash

exec {buildozer} "$@"
""".format(buildozer = buildozer.short_path),
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
    toolchains = ["@buildifier_prebuilt//:toolchain"],
    executable = True,
)
