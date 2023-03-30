"""
Rules to use the prebuilt buildifier / buildozer binaries
"""

load("//buildifier:buildifier_binary.bzl", _buildifier_binary = "buildifier_binary")
load("//buildozer:buildozer_binary.bzl", _buildozer_binary = "buildozer_binary")
load(
    "//buildifier:factory.bzl",
    "buildifier_attr_factory",
    "buildifier_impl_factory",
)

buildifier_binary = _buildifier_binary
buildozer_binary = _buildozer_binary

def _buildifier_impl(ctx):
    return [buildifier_impl_factory(ctx, test_rule = False)]

buildifier = rule(
    implementation = _buildifier_impl,
    attrs = buildifier_attr_factory(test_rule = False),
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
    executable = True,
)

def _buildifier_test_impl(ctx):
    return [buildifier_impl_factory(ctx, test_rule = True)]

_buildifier_test = rule(
    implementation = _buildifier_test_impl,
    attrs = buildifier_attr_factory(test_rule = True),
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
    test = True,
)

def buildifier_test(**kwargs):
    """
    Wrapper for the _buildifier_test rule. Optionally disables sandboxing and caching.
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
