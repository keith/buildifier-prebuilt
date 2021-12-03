# buildifier-prebuilt

This repo contains bazel rules for `buildifier` and `buildozer` using
prebuilt binaries with bazel toolchains instead of requiring you depend
on `rules_go`. This also means you won't download every possible version
of these binaries, you'll only download the ones for the platform you're
running on.

## Usage

You can create a rule for running buildifier:

```bzl
load("@buildifier_prebuilt//:rules.bzl", "buildifier")

buildifier(
    name = "buildifier.check",
    exclude_patterns = [
        "./.git/*",
    ],
    lint_mode = "warn",
    mode = "diff",
)
```

That can be run with:

```sh
bazel run //:buildifier.check
```

Or you can run buildifier or buildozer directly:

```sh
bazel run -- @buildifier_prebuilt//:buildozer ARGS
bazel run -- @buildifier_prebuilt//:buildifier ARGS
```

## Installation

Checkout [the releases
page](https://github.com/keith/buildifier-prebuilt/releases) for
snippets for your WORKSPACE
