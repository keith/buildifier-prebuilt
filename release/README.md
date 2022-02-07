# Release Process for buildifier-prebuilt

This document describes how to create a release.


## How to Create a Release

Once all of the code for a release has been merged to `main`, the release process can be started
using the command line or the GitHub Actions web interface.


### Create Release from Command Line

The release process can be started by executing the `//release:create` target specifying the desired
release tag (e.g. 1.2.3). To create a release tagged with `0.1.4`, one would run the following:

```sh
# Launch release GitHub Actions release workflow for 0.1.4
$ bazel run //release:create -- 0.1.4
```

## Create Release from GitHub Actions Web Interface

To start the release process from the GitHub Actions web interface, 

1. Navigate to the [Create
   Release](https://github.com/keith/buildifier-prebuilt/actions/workflows/create_release.yml)
   workflow page. 
2. Click the `Run workflow` dropdown button. It is located on the right-hand side of the page under
   the workflow execution filter controls.
3. In the `release_tag` textbox, enter the release tag that should be created (e.g. `1.2.3`).
4. Click the green `Run workflow` button.
