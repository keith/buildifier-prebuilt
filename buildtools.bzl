load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:types.bzl", "types")

_TOOL_NAMES = ["buildifier", "buildozer"]
_TYPICAL_PLATFORMS = ["darwin", "linux"]
_TYPICAL_ARCHES = ["amd64", "arm64"]
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

def _create_assets(version, names = _TOOL_NAMES, platforms = _TYPICAL_PLATFORMS, arches = _TYPICAL_ARCHES, sha256_values = {}):
    """Create a `list` of asset `struct` values.

    Args:
        version: The buildtools version string.
        names: Optional. A `list` of tools to include.
        platforms: Optional. A `list` of platforms to include.
        arches: Optional. A `list` of arches to include.

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
                assets.append(_create_asset(
                    name = name,
                    platform = platform,
                    arch = arch,
                    version = version,
                    sha256 = sha256_values.get(uniq_name),
                ))
    return assets

# _DEFAULT_ASSETS = [
#     _create_asset("buildifier", "darwin", "amd64", "4.2.3", "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663"),
#     _create_asset("buildozer", "darwin", "amd64", "4.2.3", "edcabae1d97bdc42559d7d1d65dfe7f8970db8d95d4bc9e7bf6656a9f2fb5592"),
#     _create_asset("buildifier", "darwin", "arm64", "4.2.3", "9434043897a3c3821fda87046918e5a6c4320d8352df700f62046744c4d168a3"),
#     _create_asset("buildozer", "darwin", "arm64", "4.2.3", "f8d0994620dec1247328f13db1d434b6489dd007f8e9b961dbd9363bc6fe7071"),
#     _create_asset("buildifier", "linux", "amd64", "4.2.3", "a19126536bae9a3917a7fc4bdbbf0378371a1d1683ab2415857cf53bce9dee49"),
#     _create_asset("buildozer", "linux", "amd64", "4.2.3", "6b4177321b770fb788b618caa453d34561b8c05081ae8b27657e527c2a3b5d52"),
# ]

_DEFAULT_ASSETS = _create_assets(version = "4.2.3", sha256_values = {
    "buildifier_darwin_amd64": "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663",
    "buildozer_darwin_amd64": "edcabae1d97bdc42559d7d1d65dfe7f8970db8d95d4bc9e7bf6656a9f2fb5592",
    "buildifier_darwin_arm64": "9434043897a3c3821fda87046918e5a6c4320d8352df700f62046744c4d168a3",
    "buildozer_darwin_arm64": "f8d0994620dec1247328f13db1d434b6489dd007f8e9b961dbd9363bc6fe7071",
    "buildifier_linux_amd64": "a19126536bae9a3917a7fc4bdbbf0378371a1d1683ab2415857cf53bce9dee49",
    "buildozer_linux_amd64": "6b4177321b770fb788b618caa453d34561b8c05081ae8b27657e527c2a3b5d52",
})

buildtools = struct(
    create_asset = _create_asset,
    create_unique_name = _create_unique_name,
    asset_to_json = _asset_to_json,
    asset_from_json = _asset_from_json,
    create_assets = _create_assets,
    DEFAULT_ASSETS = _DEFAULT_ASSETS,
)
