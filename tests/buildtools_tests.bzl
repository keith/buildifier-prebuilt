"""
Unit test setup
"""

load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//:buildtools.bzl", "buildtools")

def _create_asset_test(ctx):
    env = unittest.begin(ctx)

    actual = buildtools.create_asset(
        name = "buildifier",
        platform = "linux",
        arch = "amd64",
        version = "1.2.3",
        sha256 = "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663",
    )
    expected = struct(
        name = "buildifier",
        platform = "linux",
        arch = "amd64",
        version = "1.2.3",
        sha256 = "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663",
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

create_asset_test = unittest.make(_create_asset_test)

def _create_unique_name_test(ctx):
    env = unittest.begin(ctx)

    asset = buildtools.create_asset(
        name = "buildifier",
        platform = "linux",
        arch = "amd64",
        version = "1.2.3",
        sha256 = "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663",
    )
    actual = buildtools.create_unique_name(asset)
    asserts.equals(env, "buildifier_linux_amd64", actual)

    actual = buildtools.create_unique_name(name = "buildifier", platform = "linux", arch = "amd64")
    asserts.equals(env, "buildifier_linux_amd64", actual)

    return unittest.end(env)

create_unique_name_test = unittest.make(_create_unique_name_test)

def _default_assets_test(ctx):
    env = unittest.begin(ctx)

    asserts.true(env, len(buildtools.DEFAULT_ASSETS) > 0)

    return unittest.end(env)

default_assets_test = unittest.make(_default_assets_test)

def _asset_json_roundtrip_test(ctx):
    env = unittest.begin(ctx)

    # Single asset
    expected = buildtools.create_asset(
        name = "buildifier",
        platform = "linux",
        arch = "amd64",
        version = "1.2.3",
        sha256 = "deadbeef",
    )
    asset_json = buildtools.asset_to_json(expected)
    actual = buildtools.asset_from_json(asset_json)
    asserts.equals(env, expected, actual)

    # List of assets
    expected = [
        buildtools.create_asset(
            name = "buildifier",
            platform = "linux",
            arch = "amd64",
            version = "1.2.3",
            sha256 = "deadbeef",
        ),
        buildtools.create_asset(
            name = "buildozer",
            platform = "linux",
            arch = "amd64",
            version = "1.2.3",
            sha256 = "deadbeef",
        ),
    ]
    asset_json = buildtools.asset_to_json(expected)
    actual = buildtools.asset_from_json(asset_json)
    asserts.equals(env, expected, actual)

    return unittest.end(env)

asset_json_roundtrip_test = unittest.make(_asset_json_roundtrip_test)

def _create_assets_test(ctx):
    env = unittest.begin(ctx)

    shas = {
        "buildifier_darwin_amd64": "309b3c3bfcc4b1533d5f7f796adbd266235cfb6f01450f3e37423527d209a309",
        "buildifier_darwin_arm64": "e08381a3ed1d59c0a17d1cee1d4e7684c6ce1fc3b5cfa1bd92a5fe978b38b47d",
        "buildifier_linux_amd64": "3e79e6c0401b5f36f8df4dfc686127255d25c7eddc9599b8779b97b7ef4cdda7",
        "buildifier_linux_arm64": "c624a833bfa64d3a457ef0235eef0dbda03694768aab33f717a7ffd3f803d272",
        "buildifier_linux_riscv64": "493dc831ab318b77ff7004982b6280b5c60c7a087e56fdd4b761081806217de3",
        "buildifier_windows_amd64": "a27fcf7521414f8214787989dcfb2ac7d3f7c28b56e44384e5fa06109953c2f1",
        "buildozer_darwin_amd64": "b7bd7189a9d4de22c10fd94b7d1d77c68712db9bdd27150187bc677e8c22960e",
        "buildozer_darwin_arm64": "781527c5337dadba5a0611c01409c669852b73b72458650cc7c5f31473f7ae3f",
        "buildozer_linux_amd64": "0e54770aa6148384d1edde39ef20e10d2c57e8c09dd42f525e100f51b0b77ae1",
        "buildozer_linux_arm64": "a9f38f2781de41526ce934866cb79b8b5b59871c96853dc5a1aee26f4c5976bb",
        "buildozer_linux_riscv64": "a1f7e55c7e4a31407fe1e88dc3828938daed502089070e85826d47a6634a11e8",
        "buildozer_windows_amd64": "8ce5a9a064b01551ffb8d441fa9ef4dd42c9eeeed6bc71a89f917b3474fd65f6",
    }

    # Test use defaults
    assets = buildtools.create_assets(version = "8.2.0", sha256_values = shas)

    # 2 tools * (2 mac arches + 3 linux arches + 1 windows arch)
    asserts.equals(env, 12, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["8.2.0"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier", "buildozer"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["darwin", "linux", "windows"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64", "arm64", "riscv64"])))

    # Test with custom names
    assets = buildtools.create_assets(version = "8.2.0", names = ["buildifier"], sha256_values = shas)

    # 2 mac arches + 3 linux arches + 1 windows arch
    asserts.equals(env, 6, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["8.2.0"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["darwin", "linux", "windows"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64", "arm64", "riscv64"])))

    # Test with custom platforms
    assets = buildtools.create_assets(version = "8.2.0", platforms = ["linux"], sha256_values = shas)
    asserts.equals(env, 6, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["8.2.0"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier", "buildozer"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["linux"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64", "arm64", "riscv64"])))

    # Test with custom arches
    assets = buildtools.create_assets(version = "8.2.0", arches = ["amd64"], sha256_values = shas)

    # 2 tools * 3 oses
    asserts.equals(env, 6, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["8.2.0"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier", "buildozer"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["darwin", "linux", "windows"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64"])))

    # Test with sha256 values
    assets = buildtools.create_assets(version = "8.2.0", sha256_values = shas)
    target = None
    for asset in assets:
        if asset.name == "buildifier" and asset.platform == "darwin" and asset.arch == "amd64":
            target = asset
            break
    asserts.equals(env, "309b3c3bfcc4b1533d5f7f796adbd266235cfb6f01450f3e37423527d209a309", target.sha256)
    target = None
    for asset in assets:
        if asset.name == "buildozer" and asset.platform == "linux" and asset.arch == "amd64":
            target = asset
            break
    asserts.equals(env, "0e54770aa6148384d1edde39ef20e10d2c57e8c09dd42f525e100f51b0b77ae1", target.sha256)
    for asset in assets:
        if asset.name == "buildifier" and asset.platform == "windows" and asset.arch == "amd64":
            target = asset
            break
    asserts.equals(env, "a27fcf7521414f8214787989dcfb2ac7d3f7c28b56e44384e5fa06109953c2f1", target.sha256)

    return unittest.end(env)

create_assets_test = unittest.make(_create_assets_test)

def buildtools_test_suite():
    return unittest.suite(
        "buildtools_tests",
        create_asset_test,
        create_unique_name_test,
        default_assets_test,
        asset_json_roundtrip_test,
        create_assets_test,
    )
