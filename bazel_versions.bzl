"""
Common bazel version requirements for tests
"""

CURRENT_BAZEL_VERSION = "6.0.0"

OTHER_BAZEL_VERSIONS = [
    "5.4.0",
]

SUPPORTED_BAZEL_VERSIONS = [
    CURRENT_BAZEL_VERSION,
] + OTHER_BAZEL_VERSIONS
