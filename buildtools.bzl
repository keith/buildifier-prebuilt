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
    version = "v10.2.0",
    names = _TOOL_NAMES,
    platforms = _TYPICAL_PLATFORMS,
    arches = _TYPICAL_ARCHES,
    sha256_values = {
        "buildifier_darwin_amd64": "9e78881e91266e3567ed6d590f6c19bb5cd8cfa7aa80c7e1b6e479264d1051b8",
        "buildifier_darwin_arm64": "d9c9c3a2826d1d8f592a9d463e62aed7f4dcacc5ab48e8de6be53c420b34b971",
        "buildifier_linux_amd64": "470844069d710d0b7740e55007071c63e4d00be89a833dce5d1a91790e84dc28",
        "buildifier_linux_arm64": "e33b41bdb36eca5dfa69647333f4f148272654b98cddcea12f38fac5ec0a00ff",
        "buildifier_linux_riscv64": "2d175afe32c80340a105e85a0b533b11cef5ed0e7d5eefe72419477c2d08770e",
        "buildifier_linux_s390x": "312386b02013cb11ab932af108f46ffc24577672402a196dc764099f15c064a5",
        "buildifier_windows_amd64": "ae9b0632ff4bc56607b9c8512716b7fd63371387136005d25e94ec668f89361d",
        "buildifier_windows_arm64": "bf213d214296346f859a6f1135168161cf86d7c1ca49df41426790a139b574e8",
        "buildozer_darwin_amd64": "b569919f655931bae2e3e116597a5496c7539ed29adf8ac2c959bddbbad45b55",
        "buildozer_darwin_arm64": "373f1c6c35b41c294b3a473c569e7e99dbfbc71197d7c2a45fce5cea7134e858",
        "buildozer_linux_amd64": "0cfa2633184880ad5139bad3133fdf1a11ce3b7d37ba3eae9a85374a613c4779",
        "buildozer_linux_arm64": "82bc376fafedd281579beb400be430d4c3f0104c1a8502d10e0cb7ec2c8cb5bd",
        "buildozer_linux_riscv64": "30ca076a5c4bfb3d985a16058dcb70bba695c47b97eb0b07a3d3c624e75d9fd7",
        "buildozer_linux_s390x": "1a441035e3f6c61b13ca5c652022be59cf4302304b8618b4fefbc8426464cb7a",
        "buildozer_windows_amd64": "0166ba26a86b4576ac38325b8237a436c16ca0b956694bc933237593993caa17",
        "buildozer_windows_arm64": "297902fb6479f699e3036d2281c7edccec4f48061fae1a2342911a8041c5c3c6",
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
