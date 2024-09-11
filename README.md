# buildifier-prebuilt

[![Build](https://github.com/keith/buildifier-prebuilt/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/keith/buildifier-prebuilt/actions/workflows/ci.yml)

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

### Bzlmod: Add `bazel_dep` to `MODULE.bazel` file

<!-- BEGIN MODULE SNIPPET -->
```python
bazel_dep(
    name = "buildifier_prebuilt",
    version = "7.3.1",
    dev_dependency = True,
)
```
<!-- END MODULE SNIPPET -->


### Legacy: Add declarations to `WORKSPACE` file

Add the following to your `WORKSPACE` file.

<!-- BEGIN WORKSPACE SNIPPET -->
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "7f85b688a4b558e2d9099340cfb510ba7179f829454fba842370bccffb67d6cc",
    strip_prefix = "buildifier-prebuilt-7.3.1",
    urls = [
        "http://github.com/keith/buildifier-prebuilt/archive/7.3.1.tar.gz",
    ],
)

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()
```
<!-- END WORKSPACE SNIPPET -->


## Specify Version of Buildtools

By default releases of these rules hardcode the most up to date versions of the tools at release
time. If you would like to specify a specific version of buildtools to use, you can do one of the
following.

### Option 1: Quick and Easy

Update the `buildifier_prebuilt_register_toolchains` declaration in your `WORKSPACE` file to specify
the version.

```bzl
# Use buildtools version 4.2.5.

# Bzlmod
buildifier_prebuilt = use_extension("//:defs.bzl", "buildifier_prebuilt_deps_extension")
buildifier_prebuilt.toolchains(version = "4.2.5")
use_repo(
    buildifier_prebuilt,
    "buildifier_prebuilt_toolchains",
)

# Workspace
buildifier_prebuilt_register_toolchains(
    assets = buildtools_assets(version = "4.2.5"),
)
```

The above example will download version 4.2.5 of the `buildtools` binaries. The only downside is
that you will see warnings stating that a canonical version can be specified using SHA256 values.


### Option 2: Manually Add SHA256 Values

To add SHA256 values to the declaration, add a `sha256_values` attribute and specify the values in a
`dict` where the key is `<tool>_<platform>_<arch>` and the value is the SHA256 value.

```bzl
# Use buildtools version 4.2.5.

# Bzlmod
buildifier_prebuilt = use_extension("//:defs.bzl", "buildifier_prebuilt_deps_extension")
buildifier_prebuilt.toolchains(
    sha256_values = {
        "buildifier_darwin_amd64": "757f246040aceb2c9550d02ef5d1f22d3ef1ff53405fe76ef4c6239ef1ea2cc1",
        "buildifier_darwin_arm64": "4cf02e051f6cda18765935cb6e77cc938cf8b405064589a50fe9582f82c7edaf",
        "buildifier_linux_amd64": "f94e71b22925aff76ce01a49e1c6c6d31f521bbbccff047b81f2ea01fd01a945",
        "buildifier_linux_arm64": "2113d79e45efb51e2b3013c8737cb66cadae3fd89bd7e820438cb06201e50874",
        "buildozer_darwin_amd64": "3fe671620e6cb7d2386f9da09c1de8de88b02b9dd9275cdecd8b9e417f74df1b",
        "buildozer_darwin_arm64": "ff4d297023fe3e0fd14113c78f04cef55289ca5bfe5e45a916be738b948dc743",
        "buildozer_linux_amd64": "e8e39b71c52318a9030dd9fcb9bbfd968d0e03e59268c60b489e6e6fc1595d7b",
        "buildozer_linux_arm64": "96227142969540def1d23a9e8225524173390d23f3d7fd56ce9c4436953f02fc",
    },
    version = "4.2.5",
)
use_repo(
    buildifier_prebuilt,
    "buildifier_prebuilt_toolchains",
)

# Workspace
buildifier_prebuilt_register_toolchains(
    assets = buildtools_assets(version = "4.2.5"),
    sha256_values = {
        "buildifier_darwin_amd64": "757f246040aceb2c9550d02ef5d1f22d3ef1ff53405fe76ef4c6239ef1ea2cc1",
        "buildifier_darwin_arm64": "4cf02e051f6cda18765935cb6e77cc938cf8b405064589a50fe9582f82c7edaf",
        "buildifier_linux_amd64": "f94e71b22925aff76ce01a49e1c6c6d31f521bbbccff047b81f2ea01fd01a945",
        "buildifier_linux_arm64": "2113d79e45efb51e2b3013c8737cb66cadae3fd89bd7e820438cb06201e50874",
        "buildozer_darwin_amd64": "3fe671620e6cb7d2386f9da09c1de8de88b02b9dd9275cdecd8b9e417f74df1b",
        "buildozer_darwin_arm64": "ff4d297023fe3e0fd14113c78f04cef55289ca5bfe5e45a916be738b948dc743",
        "buildozer_linux_amd64": "e8e39b71c52318a9030dd9fcb9bbfd968d0e03e59268c60b489e6e6fc1595d7b",
        "buildozer_linux_arm64": "96227142969540def1d23a9e8225524173390d23f3d7fd56ce9c4436953f02fc",
    },
)
```

The downside to this is that you will need to manually download each binary that you will use in
your builds and calculate the SHA256 value.


### Option 3: Quick, Easy and Canonical

We have included a utility which will generate a `buildifier_prebuilt_register_toolchains`
declaration with the appropriate SHA256 values. If you execute it without any arguments, it will
use the latest release of `buildtools`. Just copy and paste the declaration into your `WORKSPACE`
file.

```sh
# Generate the declaration for the latest
$ bazel run //tools:generate_assets_declaration
load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains", "buildtools_assets")

buildifier_prebuilt_register_toolchains(
    assets = buildtools_assets(
        version = "4.2.5",
        names = ["buildifier", "buildozer"],
        platforms = ["darwin", "linux"],
        arches = ["amd64", "arm64"],
        sha256_values = {
            "buildifier_darwin_amd64": "757f246040aceb2c9550d02ef5d1f22d3ef1ff53405fe76ef4c6239ef1ea2cc1",
            "buildifier_darwin_arm64": "4cf02e051f6cda18765935cb6e77cc938cf8b405064589a50fe9582f82c7edaf",
            "buildifier_linux_amd64": "f94e71b22925aff76ce01a49e1c6c6d31f521bbbccff047b81f2ea01fd01a945",
            "buildifier_linux_arm64": "2113d79e45efb51e2b3013c8737cb66cadae3fd89bd7e820438cb06201e50874",
            "buildozer_darwin_amd64": "3fe671620e6cb7d2386f9da09c1de8de88b02b9dd9275cdecd8b9e417f74df1b",
            "buildozer_darwin_arm64": "ff4d297023fe3e0fd14113c78f04cef55289ca5bfe5e45a916be738b948dc743",
            "buildozer_linux_amd64": "e8e39b71c52318a9030dd9fcb9bbfd968d0e03e59268c60b489e6e6fc1595d7b",
            "buildozer_linux_arm64": "96227142969540def1d23a9e8225524173390d23f3d7fd56ce9c4436953f02fc",
        },
    ),
)
```

You may also specify a specific version of `buildtools` by adding it to the end of the command.

```sh
# Generate the declaration for version 4.2.3
$ bazel run //tools:generate_assets_declaration -- 4.2.3
load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains", "buildtools_assets")

buildifier_prebuilt_register_toolchains(
    assets = buildtools_assets(
        version = "4.2.3",
        names = ["buildifier", "buildozer"],
        platforms = ["darwin", "linux"],
        arches = ["amd64", "arm64"],
        sha256_values = {
            "buildifier_darwin_amd64": "954ec397089344b1564e45dc095e9331e121eb0f20e72032fcc8e94de78e5663",
            "buildifier_darwin_arm64": "9434043897a3c3821fda87046918e5a6c4320d8352df700f62046744c4d168a3",
            "buildifier_linux_amd64": "a19126536bae9a3917a7fc4bdbbf0378371a1d1683ab2415857cf53bce9dee49",
            "buildifier_linux_arm64": "39bd9d01d3638902a1e4cef353048ed160f0575f5df1bef175bd7637386d183c",
            "buildozer_darwin_amd64": "edcabae1d97bdc42559d7d1d65dfe7f8970db8d95d4bc9e7bf6656a9f2fb5592",
            "buildozer_darwin_arm64": "f8d0994620dec1247328f13db1d434b6489dd007f8e9b961dbd9363bc6fe7071",
            "buildozer_linux_amd64": "6b4177321b770fb788b618caa453d34561b8c05081ae8b27657e527c2a3b5d52",
            "buildozer_linux_arm64": "edfa964b283352ffd7503faca503de8f06dfcd1c7c96a6737e9452167e93c687",
        },
    ),
)
```

NOTE: The utility uses the [GitHub CLI](https://cli.github.com/). If you haven't already done so,
install it.
