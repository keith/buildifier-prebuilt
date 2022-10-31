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
    return [buildifier_impl_factory(ctx)]

_buildifier = rule(
    implementation = _buildifier_impl,
    attrs = buildifier_attr_factory(),
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
    executable = True,
)

def buildifier(**kwargs):
    """
    Wrapper for the _buildifier rule. Adds 'manual' to the tags.
    Args:
      **kwargs: all parameters for _buildifier
    """

    tags = kwargs.get("tags", [])
    if "manual" not in tags:
        tags.append("manual")
        kwargs["tags"] = tags
    _buildifier(**kwargs)

def _buildifier_test_impl(ctx):
    return [buildifier_impl_factory(ctx, test_rule = True)]

buildifier_test = rule(
    implementation = _buildifier_test_impl,
    attrs = buildifier_attr_factory(True),
    toolchains = ["@buildifier_prebuilt//buildifier:toolchain"],
    test = True,
)
