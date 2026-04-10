"""
Rules to use the prebuilt buildifier / buildozer binaries
"""

load("@bazel_features//:features.bzl", "bazel_features")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")
load("//buildifier:buildifier_binary.bzl", _buildifier_binary = "buildifier_binary")
load(
    "//buildifier:factory.bzl",
    "buildifier_attr_factory",
    "buildifier_impl_factory",
)
load("//buildozer:buildozer_binary.bzl", _buildozer_binary = "buildozer_binary")

_TEST_TOOLCHAIN = bazel_features.toolchains.has_default_test_toolchain_type

buildifier_binary = _buildifier_binary
buildozer_binary = _buildozer_binary

def _buildifier_impl(ctx):
    return [buildifier_impl_factory(ctx, test_rule = False)]

buildifier = rule(
    implementation = _buildifier_impl,
    attrs = buildifier_attr_factory(test_rule = False),
    exec_compatible_with = [] if _TEST_TOOLCHAIN else HOST_CONSTRAINTS,
    toolchains = [
        "@buildifier_prebuilt//buildifier:toolchain",
    ] + ([
        "@bazel_tools//tools/test:default_test_toolchain_type",
    ] if _TEST_TOOLCHAIN else []),
    executable = True,
)

def _buildifier_test_impl(ctx):
    return [buildifier_impl_factory(ctx, test_rule = True)]

_buildifier_test = rule(
    implementation = _buildifier_test_impl,
    attrs = buildifier_attr_factory(test_rule = True),
    exec_compatible_with = HOST_CONSTRAINTS,
    exec_groups = {
        "test": exec_group(
            toolchains = [
                "@buildifier_prebuilt//buildifier:toolchain",
            ] + ([
                "@bazel_tools//tools/test:default_test_toolchain_type",
            ] if _TEST_TOOLCHAIN else []),
        ),
    },
    test = True,
)

def buildifier_test(**kwargs):
    """Wrapper for the _buildifier_test rule. Optionally disables sandboxing and caching.

    Args:
      **kwargs: all parameters for _buildifier_test
    """
    if kwargs.get("no_sandbox", False):
        tags = kwargs.get("tags", [])

        # Note: the "external" tag is a workaround for
        # https://github.com/bazelbuild/bazel/issues/15516.
        for t in ["no-sandbox", "no-cache", "external"]:
            if t not in tags:
                tags.append(t)
        kwargs["tags"] = tags
    _buildifier_test(**kwargs)
