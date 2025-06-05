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
    version = "v8.2.0",
    names = ["buildifier", "buildozer"],
    platforms = ["darwin", "linux", "windows"],
    arches = ["amd64", "arm64"],
    sha256_values = {
        "buildifier_darwin_amd64": "309b3c3bfcc4b1533d5f7f796adbd266235cfb6f01450f3e37423527d209a309",
        "buildifier_darwin_arm64": "e08381a3ed1d59c0a17d1cee1d4e7684c6ce1fc3b5cfa1bd92a5fe978b38b47d",
        "buildifier_linux_amd64": "3e79e6c0401b5f36f8df4dfc686127255d25c7eddc9599b8779b97b7ef4cdda7",
        "buildifier_linux_arm64": "c624a833bfa64d3a457ef0235eef0dbda03694768aab33f717a7ffd3f803d272",
        "buildifier_windows_amd64": "a27fcf7521414f8214787989dcfb2ac7d3f7c28b56e44384e5fa06109953c2f1",
        "buildozer_darwin_amd64": "b7bd7189a9d4de22c10fd94b7d1d77c68712db9bdd27150187bc677e8c22960e",
        "buildozer_darwin_arm64": "781527c5337dadba5a0611c01409c669852b73b72458650cc7c5f31473f7ae3f",
        "buildozer_linux_amd64": "0e54770aa6148384d1edde39ef20e10d2c57e8c09dd42f525e100f51b0b77ae1",
        "buildozer_linux_arm64": "a9f38f2781de41526ce934866cb79b8b5b59871c96853dc5a1aee26f4c5976bb",
        "buildozer_windows_amd64": "8ce5a9a064b01551ffb8d441fa9ef4dd42c9eeeed6bc71a89f917b3474fd65f6",
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
