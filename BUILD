load(
    "@buildifier_prebuilt//:rules.bzl",
    "buildifier_binary",
    "buildozer_binary",
)

exports_files(
    ["runner.bash.template"],
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain",
    visibility = ["//visibility:public"],
)

buildifier_binary(
    name = "buildifier",
    visibility = ["//visibility:public"],
)

buildozer_binary(
    name = "buildozer",
    visibility = ["//visibility:public"],
)
