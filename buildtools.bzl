"""
Setup code for setting up binaries for use
"""

load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:types.bzl", "types")

_TOOL_NAMES = ["buildifier", "buildozer"]
_TYPICAL_PLATFORMS = ["windows", "darwin", "linux"]
_TYPICAL_ARCHES = ["amd64", "arm64", "riscv64"]
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
                if platform == "windows" and arch == "arm64":
                    continue
                if platform == "windows" and arch == "riscv64":
                    continue
                if platform == "darwin" and arch == "riscv64":
                    continue

                uniq_name = _create_unique_name(
                    name = name,
                    platform = platform,
                    arch = arch,
                )

                if uniq_name not in sha256_values:
                    fail("Missing sha256 value for {}".format(uniq_name))

                assets.append(_create_asset(
                    name = name,
                    platform = platform,
                    arch = arch,
                    version = version,
                    sha256 = sha256_values.get(uniq_name),
                ))
    return assets

_DEFAULT_ASSETS = _create_assets(
    version = "v8.2.1",
    names = ["buildifier", "buildozer"],
    platforms = ["darwin", "linux", "windows"],
    arches = ["amd64", "arm64", "riscv64"],
    sha256_values = {
        "buildifier_darwin_amd64": "9f8cffceb82f4e6722a32a021cbc9a5344b386b77b9f79ee095c61d087aaea06",
        "buildifier_darwin_arm64": "cfab310ae22379e69a3b1810b433c4cd2fc2c8f4a324586dfe4cc199943b8d5a",
        "buildifier_linux_amd64": "6ceb7b0ab7cf66fceccc56a027d21d9cc557a7f34af37d2101edb56b92fcfa1a",
        "buildifier_linux_arm64": "3baa1cf7eb41d51f462fdd1fff3a6a4d81d757275d05b2dd5f48671284e9a1a5",
        "buildifier_linux_riscv64": "5101795c6b90e3aca6d8dc4efe15fd818a8b6053f34284551f6ba7fa57ad8415",
        "buildifier_windows_amd64": "802104da0bcda0424a397ac5be0004c372665a70289a6d5146e652ee497c0dc6",
        "buildozer_darwin_amd64": "1284b7416d9ebbb50033645fc648985f9b2e0f38e7f22f79c0398c97d38d146c",
        "buildozer_darwin_arm64": "a981182561f67ed697b0e810714307c8475bce68c069f819212fe36f12d77872",
        "buildozer_linux_amd64": "04454a6a89c64c603027cc3371eb1c36e48727e04558e077c20ec37c9c2f831a",
        "buildozer_linux_arm64": "e55b56861a390cc993402d2974d5b74a097694f64eb08599dc704bdd7dde6484",
        "buildozer_linux_riscv64": "4efc096f6b23e81db035344706c12daf6795fdff0a1edb7af8d96bc60ea631dc",
        "buildozer_windows_amd64": "6e3b8520904394adc31a610544fc2f86609c0433e39ae3a5b5f992e20dabb0d3",
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
