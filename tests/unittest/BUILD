load("@rules_shell//shell:sh_library.bzl", "sh_library")

# https://www.stevenengelhardt.com/2023/02/26/practical-bazel-using-bazels-bash-unittest-framework/

sh_library(
    name = "unittest",
    srcs = [
        "unittest.bash",
        "unittest_utils.sh",
    ],
    visibility = ["//tests:__subpackages__"],
)
