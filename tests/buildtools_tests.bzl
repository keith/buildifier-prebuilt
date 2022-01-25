load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
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

def buildtools_test_suite():
    return unittest.suite(
        "buildtools_tests",
        create_asset_test,
        default_assets_test,
        asset_json_roundtrip_test,
    )
