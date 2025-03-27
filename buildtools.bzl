"""
Setup code for setting up binaries for use
"""

load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:types.bzl", "types")

_TOOL_NAMES = ["buildifier", "buildozer"]
_TYPICAL_PLATFORMS = ["windows", "darwin", "linux"]
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
    if arch == "windows" and version == "arm64":
        fail("arm64 windows executables are not provided by buildifier/buildozer")
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
                if platform == "windows" and arch == "arm64":
                    continue

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

_DEFAULT_ASSETS = _create_assets(
    version = "v8.0.3",
    names = ["buildifier", "buildozer"],
    platforms = ["darwin", "linux", "windows"],
    arches = ["amd64", "arm64"],
    sha256_values = {
        "buildifier_darwin_amd64": "b7a3152cde0b3971b1107f2274afe778c5c154dcdf6c9c669a231e3c004f047e",
        "buildifier_darwin_arm64": "674c663f7b5cd03c002f8ca834a8c1c008ccb527a0a2a132d08a7a355883b22d",
        "buildifier_linux_amd64": "c969487c1af85e708576c8dfdd0bb4681eae58aad79e68ae48882c70871841b7",
        "buildifier_linux_arm64": "bdd9b92e2c65d46affeecaefb54e68d34c272d1f4a8c5b54929a3e92ab78820a",
        "buildifier_windows_amd64": "63a242f57e253efe7b9573d739c08a3d0e628efd84015c8dad17d87b6429e443",
        "buildozer_darwin_amd64": "7aa7929faddcee5a879135356bb4d38af3e895893c78d361e7cdb8dfb3e7d5e4",
        "buildozer_darwin_arm64": "33b776862c31bfb4e2e6e88186cae02746d9084da8b7341930e77d42718277cc",
        "buildozer_linux_amd64": "775d17118aecd023352e75611dbe7c12a340e23615ffb270a1dec3f339239949",
        "buildozer_linux_arm64": "058ad60f279a7b1db339bb287aed2056a992eddfe1b5d2e56d86256bdc9a93b3",
        "buildozer_windows_amd64": "5ba106b25230e0e321b7259bee325ae6fa5b5771e54163ad865b1d18856f59ca",
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
