load(
    "@cgrindel_bazel_starlib//bzlrelease:defs.bzl",
    "create_release",
    "generate_release_notes",
    "generate_workspace_snippet",
    "update_readme",
)

# MARK: - Release

generate_workspace_snippet(
    name = "generate_workspace_snippet",
    template = "workspace_snippet.tmpl",
    workspace_name = "buildifier_prebuilt",
)

generate_release_notes(
    name = "generate_release_notes",
    generate_workspace_snippet = ":generate_workspace_snippet",
)

update_readme(
    name = "update_readme",
    generate_workspace_snippet = ":generate_workspace_snippet",
)

create_release(
    name = "create",
    workflow_name = "Create Release",
)
