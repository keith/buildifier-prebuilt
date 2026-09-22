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
    version = "v10.1.0",
    names = _TOOL_NAMES,
    platforms = _TYPICAL_PLATFORMS,
    arches = _TYPICAL_ARCHES,
    sha256_values = {
        "buildifier_darwin_amd64": "e9e10ff52ec8786fcabccd251c8109ebf31ef7be1f667e27c6e069b96dbdc1f6",
        "buildifier_darwin_arm64": "e9804864c407f920f5ecbf03a5e056a8145e11a6ae6b90d2438a3fd106d34473",
        "buildifier_linux_amd64": "31b6a8aa1e5c746696788f428729701770ad91925873d8256cb885c60e12c77e",
        "buildifier_linux_arm64": "38d2ed845f560b4a16ddee41de906508a95f8dc85b04e0851b0a71e3a70d3890",
        "buildifier_linux_riscv64": "5a232555ec7c572d7ac42c72ad526ac0cc4386df81cd9d491c48e56a83350224",
        "buildifier_linux_s390x": "618f0a915dcdfac4f11e704c551dead9f0dc907b60938ff78e4dcd4d7f0c750f",
        "buildifier_windows_amd64": "931a6e9c3844b90ccdb1467ccacd8dd72457e308d2709d624a3c5880d835ac3c",
        "buildifier_windows_arm64": "aeffa5a342ce119b52cd7aa17bd9dda22b0406245d90643985749d01f51d2de1",
        "buildozer_darwin_amd64": "e9809d8ca40da421e1b5420dd735f32d13a0b01ebadfb7f519d5b7f4316061b4",
        "buildozer_darwin_arm64": "9e5d300659253c9235c50f792b46cfc5148e62513a8056e916fa2ca738b904f2",
        "buildozer_linux_amd64": "3513b8b23619f5fb7ccad546e955af6e318475582ce7b6f2b47b634bd3b8dcbd",
        "buildozer_linux_arm64": "add0e7e45e10231746c6bb193e466361183dfe9d2df8f951b62c49a047508f30",
        "buildozer_linux_riscv64": "c738733a6c2f2e163a1052b60a1f375a62b4092218716c5f3a09294d9a51fbac",
        "buildozer_linux_s390x": "15a5df3b7ba87ec2605e319708189190da0d5ecf72b48d3e8277238af5a2cae0",
        "buildozer_windows_amd64": "025217f54dc8a9abdb7647d559a607c365a63fdc1e6beb44c3b4a54773596d0f",
        "buildozer_windows_arm64": "3fd7e1b602adce139bfa733bc403b00201537b79c53930edbdaf449e5e879ae1",
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
