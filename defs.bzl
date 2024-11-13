"""
Binary buildifier / buildozer setup
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//:buildtools.bzl", "buildtools")

def _buildifier_toolchain_setup_impl(repository_ctx):
    assets = buildtools.asset_from_json(repository_ctx.attr.assets_json)

    content = 'load("@buildifier_prebuilt//:toolchain.bzl", "declare_toolchain")'
    for asset in assets:
        content += """
declare_toolchain(
    tool_name = "{tool_name}",
    tool = "@{uniq_name}//file:{tool_name}{ext}",
    os = "{platform}",
    arch = "{arch}",
)

""".format(
            uniq_name = buildtools.create_unique_name(asset),
            tool_name = asset.name,
            ext = ".exe" if asset.platform == "windows" else "",
            platform = asset.platform,
            arch = asset.arch,
        )
    repository_ctx.file("BUILD.bazel", content)

_buildifier_toolchain_setup = repository_rule(
    implementation = _buildifier_toolchain_setup_impl,
    attrs = {
        "assets_json": attr.string(
            doc = "The assets to download encoded as JSON.",
            mandatory = True,
        ),
    },
)

def buildifier_prebuilt_register_toolchains(
        name = "buildifier_prebuilt_toolchains",
        assets = buildtools.DEFAULT_ASSETS,
        register_toolchains = True):
    """Setup the buildifier toolchain and configure downloads

    Args:
        name: The name of the repository used for the toolchains.
        assets: The buildozer and buildifier assets to use.
        register_toolchains: Whether to register the toolchains.
    """
    if len(assets) == 0:
        fail("No assets were specified.")

    toolchain_names = []
    for asset in assets:
        http_file_name = buildtools.create_unique_name(asset = asset)
        http_file_ext = ".exe" if asset.platform == "windows" else ""
        http_file_args = {
            "name": http_file_name,
            "urls": [
                "https://github.com/bazelbuild/buildtools/releases/download/{version}/{name}-{platform}-{arch}{ext}".format(
                    version = asset.version,
                    name = asset.name,
                    platform = asset.platform,
                    arch = asset.arch,
                    ext = http_file_ext,
                ),
            ],
            "downloaded_file_path": asset.name + http_file_ext,
            "executable": True,
        }
        if asset.sha256:
            http_file_args["sha256"] = asset.sha256
        http_file(**http_file_args)

        toolchain_names.append("@{name}//:{uniq_name}_toolchain".format(
            name = name,
            uniq_name = http_file_name,
        ))

    _buildifier_toolchain_setup(
        name = name,
        assets_json = buildtools.asset_to_json(assets),
    )

    if register_toolchains:
        native.register_toolchains(*toolchain_names)

buildtools_asset = buildtools.create_asset
buildtools_assets = buildtools.create_assets

def _buildifier_prebuilt_deps_extension_impl(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchains in mod.tags.toolchains:
            if toolchains.name in registrations:
                continue
            registrations[toolchains.name] = True
            if not toolchains.version:
                assets = buildtools.DEFAULT_ASSETS
            else:
                kwargs = {}
                if toolchains.names:
                    kwargs["names"] = toolchains.names
                if toolchains.platforms:
                    kwargs["platforms"] = toolchains.platforms
                if toolchains.arches:
                    kwargs["arches"] = toolchains.arches
                if toolchains.sha256_values:
                    kwargs["sha256_values"] = toolchains.sha256_values
                assets = buildtools_assets(
                    version = toolchains.version,
                    **kwargs
                )
            buildifier_prebuilt_register_toolchains(
                name = toolchains.name,
                assets = assets,
                register_toolchains = toolchains.register,
            )

buildifier_prebuilt_deps_extension = module_extension(
    implementation = _buildifier_prebuilt_deps_extension_impl,
    tag_classes = {
        "toolchains": tag_class(attrs = {
            "name": attr.string(doc = "The name of the repository used for the toolchains.", default = "buildifier_prebuilt_toolchains"),
            "version": attr.string(doc = "The buildtools version string."),
            "names": attr.string_list(doc = "A list of tools to include."),
            "platforms": attr.string_list(doc = "A list of platforms to include."),
            "arches": attr.string_list(doc = "A list of arches to include."),
            "sha256_values": attr.string_dict(doc = "A dict of asset name to sha256."),
            "register": attr.bool(doc = "Whether to register the toolchains."),
        }),
    },
)
