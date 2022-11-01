"""
This module contains factory methods for simple rule and implementation generation
"""

load("@bazel_skylib//lib:shell.bzl", "shell")

def buildifier_attr_factory(*, test_rule):
    """
    Helper macro to generate a struct of attrs for use in a rule() definition.

    Args:
      test_rule: Whether or not to generate attrs for a test rule.

    Returns:
      A dictionary of attributes relevant to the rule
    """
    attrs = {
        "verbose": attr.bool(
            doc = "Print verbose information on standard error",
        ),
        "mode": attr.string(
            default = "fix" if not test_rule else "diff",
            doc = "Formatting mode",
            values = ["check", "diff", "print_if_changed"] + ["fix"] if not test_rule else [],
        ),
        "lint_mode": attr.string(
            doc = "Linting mode",
            values = ["", "warn"] + ["fix"] if not test_rule else [],
        ),
        "lint_warnings": attr.string_list(
            allow_empty = True,
            doc = "all prefixed with +/- if you want to include in or exclude from the default set of warnings, or none prefixed with +/- if you want to override the default set, or 'all' for all available warnings",
        ),
        "diff_command": attr.string(
            doc = "Command to use to show diff, with mode=diff. E.g. 'diff -u'",
        ),
        "multi_diff": attr.bool(
            default = False,
            doc = "Set to True if the diff command specified by the 'diff_command' can diff multiple files in the style of 'tkdiff'",
        ),
        "add_tables": attr.label(
            mandatory = False,
            doc = "path to JSON file with custom table definitions which will be merged with the built-in tables",
            allow_single_file = True,
        ),
        "_runner": attr.label(
            default = "@buildifier_prebuilt//:runner.bash.template",
            allow_single_file = True,
        ),
    }

    if test_rule:
        attrs.update({
            "srcs": attr.label_list(
                allow_empty = False,
                allow_files = [
                    ".bazel",
                    ".bzl",
                    ".oss",
                    ".sky",
                    "BUILD",
                    "WORKSPACE",
                ],
                doc = "A list of labels representing the starlark files to include in the test",
            ),
        })
    else:
        attrs.update({
            "exclude_patterns": attr.string_list(
                allow_empty = True,
                doc = "A list of glob patterns passed to the find command. E.g. './vendor/*' to exclude the Go vendor directory",
            ),
            "disabled_rewrites": attr.string_list(
                allow_empty = True,
                doc = "buildifier rewrites you want to disable",
            ),
        })

    return attrs

def buildifier_impl_factory(ctx, *, test_rule):
    """
    Helper macro to generate a buildifier or buildifier_test rule.

    This macro does not depend on defaults encoded in the binary, instead
    preferring to set explicit values for each flag.

    Args:
      ctx:          The execution context.
      test_rule:    Whether or not to generate a test rule.

    Returns:
      A DefaultInfo provider
    """
    args = [
        "-mode=%s" % ctx.attr.mode,
        "-v=%s" % str(ctx.attr.verbose).lower(),
    ]

    if ctx.attr.lint_mode:
        args.append("-lint=%s" % ctx.attr.lint_mode)

    if len(ctx.attr.lint_warnings) > 0 and not ctx.attr.lint_mode:
        fail("Cannot pass 'lint_warnings' without a 'lint_mode'")
    for warning in ctx.attr.lint_warnings:
        args.append("--warnings={}".format(warning))

    if ctx.attr.multi_diff:
        args.append("-multi_diff")

    if ctx.attr.diff_command:
        args.append("-diff_command=%s" % ctx.attr.diff_command)

    if ctx.attr.add_tables:
        args.append("-add_tables=%s" % ctx.file.add_tables.path)

    if not test_rule and ctx.attr.disabled_rewrites:
        args.append("-buildifier_disable={}".format(",".join(ctx.attr.disabled_rewrites)))

    exclude_patterns_str = ""
    if not test_rule and ctx.attr.exclude_patterns:
        exclude_patterns = ["\\! -path %s" % shell.quote(pattern) for pattern in ctx.attr.exclude_patterns]
        exclude_patterns_str = " ".join(exclude_patterns)

    buildifier = ctx.toolchains["@buildifier_prebuilt//buildifier:toolchain"]._tool
    out_file = ctx.actions.declare_file(ctx.label.name + ".bash")
    substitutions = {
        "@@ARGS@@": shell.array_literal(args),
        "@@BUILDIFIER_SHORT_PATH@@": shell.quote(buildifier.short_path),
        "@@EXCLUDE_PATTERNS@@": exclude_patterns_str,
    }
    ctx.actions.expand_template(
        template = ctx.file._runner,
        output = out_file,
        substitutions = substitutions,
        is_executable = True,
    )

    runfiles = [buildifier]
    if test_rule:
        runfiles.extend(ctx.files.srcs)

    return DefaultInfo(
        files = depset([out_file]),
        runfiles = ctx.runfiles(files = runfiles),
        executable = out_file,
    )
