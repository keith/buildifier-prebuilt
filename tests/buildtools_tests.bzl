load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _create_asset_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

create_asset_test = unittest.make(_create_asset_test)

def _default_assets_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

default_assets_test = unittest.make(_default_assets_test)

def buildtools_test_suite():
    return unittest.suite(
        "buildtools_tests",
        create_asset_test,
        default_assets_test,
    )
