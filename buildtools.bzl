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
    if arch == "windows" and version == "arm64":
        fail("arm64 windows executables are not provided by buildifier/buildozer")
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
    version = "v8.5.1",
    names = _TOOL_NAMES,
    platforms = _TYPICAL_PLATFORMS,
    arches = _TYPICAL_ARCHES,
    sha256_values = {
        "buildifier_darwin_amd64": "31de189e1a3fe53aa9e8c8f74a0309c325274ad19793393919e1ca65163ca1a4",
        "buildifier_darwin_arm64": "62836a9667fa0db309b0d91e840f0a3f2813a9c8ea3e44b9cd58187c90bc88ba",
        "buildifier_linux_amd64": "887377fc64d23a850f4d18a077b5db05b19913f4b99b270d193f3c7334b5a9a7",
        "buildifier_linux_arm64": "947bf6700d708026b2057b09bea09abbc3cafc15d9ecea35bb3885c4b09ccd04",
        "buildifier_linux_riscv64": "90edba97d237672d33ebabf72a2d34ffbedbed25409631846ec161b1583488d2",
        "buildifier_linux_s390x": "f90975cf1afd7b3472ab559c1ce2b3785b099e53e66868d7baf0f6b6582a7c98",
        "buildifier_windows_amd64": "f4ecb9c73de2bc38b845d4ee27668f6248c4813a6647db4b4931a7556052e4e1",
        "buildozer_darwin_amd64": "b85b9ad59c1543999a5d8bc8bee6e42b9f025be3ff520bc2d090213698850b43",
        "buildozer_darwin_arm64": "d0cf2f6e11031d62bfd4584e46eb6bb708a883ff948be76538b34b83de833262",
        "buildozer_linux_amd64": "2b745ca2ad41f1e01673fb59ac50af6b45ca26105c1d20fad64c3d05a95522f5",
        "buildozer_linux_arm64": "87ee1d2d81d08ccae8f9147fc58503967c85878279e892f2990912412feef1a1",
        "buildozer_linux_riscv64": "9b0c81b873bb77ade5e439afbb78217dc72e027af6bbab2b7c39812fed545791",
        "buildozer_linux_s390x": "0b736803697d74084d81dec4c9b1297be6dd9b6f58fe49951236bfc1852b2499",
        "buildozer_windows_amd64": "e177155c2c8ef41569791de34f13077cefe3e5623f9f02e099347232bc028901",
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
