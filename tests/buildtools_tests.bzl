load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("//:buildtools.bzl", "buildtools")

def _create_asset_test(ctx):
    env = unittest.begin(ctx)

    # Test without sha256
    actual = buildtools.create_asset(
        name = "buildifier",
        platform = "linux",
        arch = "amd64",
        version = "1.2.3",
    )
    expected = struct(
        name = "buildifier",
        platform = "linux",
        arch = "amd64",
        version = "1.2.3",
        sha256 = None,
    )
    asserts.equals(env, expected, actual)

    # Test with sha256
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
        ),
        buildtools.create_asset(
            name = "buildozer",
            platform = "linux",
            arch = "amd64",
            version = "1.2.3",
        ),
    ]
    asset_json = buildtools.asset_to_json(expected)
    actual = buildtools.asset_from_json(asset_json)
    asserts.equals(env, expected, actual)

    return unittest.end(env)

asset_json_roundtrip_test = unittest.make(_asset_json_roundtrip_test)

def _create_assets_test(ctx):
    env = unittest.begin(ctx)

    # Test use defaults
    assets = buildtools.create_assets(version = "4.2.5")
    asserts.equals(env, 8, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["4.2.5"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier", "buildozer"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["darwin", "linux"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64", "arm64"])))

    # Test with custom names
    assets = buildtools.create_assets(version = "4.2.5", names = ["buildifier"])
    asserts.equals(env, 4, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["4.2.5"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["darwin", "linux"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64", "arm64"])))

    # Test with custom platforms
    assets = buildtools.create_assets(version = "4.2.5", platforms = ["linux"])
    asserts.equals(env, 4, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["4.2.5"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier", "buildozer"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["linux"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64", "arm64"])))

    # Test with custom arches
    assets = buildtools.create_assets(version = "4.2.5", arches = ["amd64"])
    asserts.equals(env, 4, len(assets))
    versions = sets.make([asset.version for asset in assets])
    asserts.true(env, sets.is_equal(versions, sets.make(["4.2.5"])))
    names = sets.make([asset.name for asset in assets])
    asserts.true(env, sets.is_equal(names, sets.make(["buildifier", "buildozer"])))
    platforms = sets.make([asset.platform for asset in assets])
    asserts.true(env, sets.is_equal(platforms, sets.make(["darwin", "linux"])))
    arches = sets.make([asset.arch for asset in assets])
    asserts.true(env, sets.is_equal(arches, sets.make(["amd64"])))

    return unittest.end(env)

create_assets_test = unittest.make(_create_assets_test)

def buildtools_test_suite():
    return unittest.suite(
        "buildtools_tests",
        create_asset_test,
        default_assets_test,
        asset_json_roundtrip_test,
        create_assets_test,
    )
