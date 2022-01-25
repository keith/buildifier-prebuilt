load("@bazel_skylib//lib:new_sets.bzl", "sets")

_VALID_ASSET_NAMES = sets.make("buildifier", "buildozer")

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
    if not sets.contains(_VALID_ASSET_NAMES, name):
        fail("Invalid asset name. {name}".format(name = name))

    return struct(
        name = name,
        platform = platform,
        arch = arch,
        version = version,
        sha256 = sha256,
    )

_DEFAULT_ASSETS = [
    _create_asset("buildifier", "darwin", "amd64", "4.2.3", "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663"),
    _create_asset("buildozer", "darwin", "amd64", "4.2.3", "edcabae1d97bdc42559d7d1d65dfe7f8970db8d95d4bc9e7bf6656a9f2fb5592"),
    _create_asset("buildifier", "darwin", "arm64", "4.2.3", "9434043897a3c3821fda87046918e5a6c4320d8352df700f62046744c4d168a3"),
    _create_asset("buildozer", "darwin", "arm64", "4.2.3", "f8d0994620dec1247328f13db1d434b6489dd007f8e9b961dbd9363bc6fe7071"),
    _create_asset("buildifier", "linux", "amd64", "4.2.3", "a19126536bae9a3917a7fc4bdbbf0378371a1d1683ab2415857cf53bce9dee49"),
    _create_asset("buildozer", "linux", "amd64", "4.2.3", "6b4177321b770fb788b618caa453d34561b8c05081ae8b27657e527c2a3b5d52"),
]

buildtools = struct(
    create_asset = _create_asset,
    DEFAULT_ASSETS = _DEFAULT_ASSETS,
)
