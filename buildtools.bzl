"""
Setup code for setting up binaries for use
"""

load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:types.bzl", "types")

_TOOL_NAMES = ["buildifier", "buildozer"]
_TYPICAL_PLATFORMS = ["windows", "darwin", "linux"]
_TYPICAL_ARCHES = ["amd64", "arm64", "riscv64", "s390x"]
_VALID_TOOL_NAMES = sets.make(_TOOL_NAMES)

def _create_asset(name, platform, arch, version, sha256 = None):
    """Create a `struct` representing a buildtools asset.

    Args:
        name: The name of the asset (e.g. `buildifier`, `buildozer`) as a
              `string`.
        platform: The platform as a `string`. (e.g. `linux`, `darwin`)
        arch: The arch as a `string`. (e.g. `amd64`, `arm64`)
        version: The version as a `string`. (e.g. `4.2.3`)
        sha256: Optional. The sha256 as a `string`.


    Returns:
        A `struct` representing the asset to be downloaded.
    """
    if name == None:
        fail("Expected a name.")
    if platform == None:
        fail("Expected a platform.")
    if arch == None:
        fail("Expected an arch.")
    if version == None:
        fail("Expected a version.")
    if sha256 == None:
        fail("Expected a sha256.")
    if arch == "windows" and version == "riscv64":
        fail("riscv64 windows executables are not provided by buildifier/buildozer")
    if arch == "darwin" and version == "riscv64":
        fail("riscv64 darwin executables are not provided by buildifier/buildozer")
    if not sets.contains(_VALID_TOOL_NAMES, name):
        fail("Invalid asset name. {name}".format(name = name))

    return struct(
        name = name,
        platform = platform,
        arch = arch,
        version = version,
        sha256 = sha256,
    )

def _create_unique_name(asset = None, name = None, platform = None, arch = None):
    """Create a unique name from an asset or from a name/platform/arch.

    Args:
        asset: An asset `struct` as returned by `buildtools.create_asset`.
        name: A tool name (e.g. buildifier) as `string`.
        platform: A platform as `string`.
        arch: An arch as `string`.

    Returns:
        A `string` suitable for use as identifying an asset.
    """
    if asset != None:
        name = asset.name
        platform = asset.platform
        arch = asset.arch
    if name == None or platform == None or arch == None:
        fail("An asset or name/platform/arch must be specified.")

    return "{name}_{platform}_{arch}".format(
        name = name,
        platform = platform,
        arch = arch,
    )

def _asset_to_json(asset):
    """Returns the JSON representation for an asset `struct` or a `list` of asset `struct` values.

    Args:
        asset: An asset `struct` as returned by `buildtools.create_asset`.

    Returns:
        Returns a JSON `string` representation of the provided value.
    """
    return json.encode(asset)

def _asset_from_json(json_str):
    """Returns an asset `struct` or a `list` of asset `struct` values as represented by the JSON `string`.

    Args:
        json_str: A JSON `string` representing an asset or a list of assets.

    Returns:
        An asset `struct` or a `list` of asset `struct` values.
    """
    result = json.decode(json_str)
    if types.is_list(result):
        return [_create_asset(**a) for a in result]
    elif types.is_dict(result):
        return _create_asset(**result)
    fail("Unexpected result type decoding JSON string. %s" % (json_str))

def _create_assets(
        version,
        names = _TOOL_NAMES,
        platforms = _TYPICAL_PLATFORMS,
        arches = _TYPICAL_ARCHES,
        sha256_values = {}):
    """Create a `list` of asset `struct` values.

    Args:
        version: The buildtools version string.
        names: Optional. A `list` of tools to include.
        platforms: Optional. A `list` of platforms to include.
        arches: Optional. A `list` of arches to include.
        sha256_values: Optional. A `dict` of asset name to sha256.

    Returns:
        A `list` of buildtools assets.
    """
    if version == None:
        fail("Expected a version.")
    if names == None or names == []:
        fail("Expected a non-empty list for names.")
    if platforms == None or platforms == []:
        fail("Expected a non-empty list for platforms.")
    if arches == None or arches == []:
        fail("Expected a non-empty list for arches.")
    if sha256_values == None:
        sha256_values = {}

    assets = []
    for name in names:
        for platform in platforms:
            for arch in arches:
                uniq_name = _create_unique_name(
                    name = name,
                    platform = platform,
                    arch = arch,
                )

                if uniq_name not in sha256_values:
                    continue

                assets.append(_create_asset(
                    name = name,
                    platform = platform,
                    arch = arch,
                    version = version,
                    sha256 = sha256_values.get(uniq_name),
                ))
    return assets

_DEFAULT_ASSETS = _create_assets(
    version = "v10.0.1",
    names = _TOOL_NAMES,
    platforms = _TYPICAL_PLATFORMS,
    arches = _TYPICAL_ARCHES,
    sha256_values = {
        "buildifier_darwin_amd64": "1d02bb9148cadf2cbee330f9bd657352c765b52b68a03d970e10e47706bdc436",
        "buildifier_darwin_arm64": "afb78f350319b59cc51d6add3a5f3ba68e63e5d88f68c5a9ea6328a07084d319",
        "buildifier_linux_amd64": "e0ea28e2d639347724435ebafe0531fd764fbf20eec6a23000c81edd0d58e51d",
        "buildifier_linux_arm64": "6d7aebd23aa85847a66d517bb6220d95f24a2752e62cce0f089145b680b539c7",
        "buildifier_linux_riscv64": "760f3811ec408dda83be9ad39c4ceaa6b1c4469335620e483007596903757d62",
        "buildifier_linux_s390x": "01774063e8751bee931b571b42d66f166cf3d49c2adb33d2fe8552137a1b16e0",
        "buildifier_windows_amd64": "ac33edf5da6137ec816f14d7a07889c96c45d669a8d58c864e9c3d0a62063fcd",
        "buildifier_windows_arm64": "cb02bf1d65ddb624dd2c20b7a7ae88bfc5d9bc3e39112888a8bc6b2f6f5faa20",
        "buildozer_darwin_amd64": "ed5e9acbd551aaa0d153c97999925f99e2310904f73bf01170f58813bf94a915",
        "buildozer_darwin_arm64": "b5c89fd313d537157c03608addcd1ed72d6ba3ae0af6ab55e3a4c132386b4d22",
        "buildozer_linux_amd64": "1dcd81b6e6d6fe2124f6196cd8d4288a1c12dda50fad7f1a01131c25498dac33",
        "buildozer_linux_arm64": "a93fb409201b42e58074e192a0bc7e73787fb7d914bd8ad986f0f10b4f4ee3af",
        "buildozer_linux_riscv64": "7f07cb1b9075b2a3c0760e931ae503a05b5bb07a1ef20de4a60bcb5ab8742a80",
        "buildozer_linux_s390x": "6b270a59f563d6225050370e42e74f3a13c50e93f57e7a43831cf56ebb4e6602",
        "buildozer_windows_amd64": "999efbec1657c5f802512731e4e02413790cf36afc9911299e7f54dccbf0be2c",
        "buildozer_windows_arm64": "c57e4f4e16a4bab2fecde2575ee1da41d134545cd6205a91ea76ae0f647b1321",
    },
)

buildtools = struct(
    create_asset = _create_asset,
    create_unique_name = _create_unique_name,
    asset_to_json = _asset_to_json,
    asset_from_json = _asset_from_json,
    create_assets = _create_assets,
    DEFAULT_ASSETS = _DEFAULT_ASSETS,
)
