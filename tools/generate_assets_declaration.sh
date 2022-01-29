#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
source "${arrays_sh}"


# MARK - Check for Required Software

is_installed gh || fail "Could not find Github CLI (gh)."
is_installed jq || fail "Could not find jq for JSON parsing."
is_installed shasum || fail "Could not find shasum."


# MARK - Usage

get_usage() {
  local utility="$(basename "${BASH_SOURCE[0]}")"
  echo "$(cat <<-EOF
Generates an assets declaration suitable for inclusion in a WORKSPACE file.

Usage:
${utility} [OPTION] [<tag>]

Options:
  --help                 Show usage.
  --verbose              Enables verbose output to stderr.
  --reset_tools          Resets the list of tools.
  --tool <tool>          Adds the specified tool to the list of tools to be 
                         retrieved.
  --reset_platforms      Resets the list of platforms.
  --platform <platform>  Adds the specified platform to the list of platforms 
                         to be retrieved.
  --reset_arches         Resets the list of arches.
  --arch <arch>          Adds the specified arch to the list of arches to be
                         retrieved
  <tag>                  The release tag.
EOF
  )"
}

# MARK - Process Args

verbose=false
tools=(buildifier buildozer)
platforms=(darwin linux)
arches=(amd64 arm64)

args=()
while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      exit 0
      ;;
    "--verbose")
      verbose=true
      shift 1
      ;;
    "--reset_tools")
      tools=()
      shift 1
      ;;
    "--tool")
      tools+=( "${2}" )
      shift 2
      ;;
    "--reset_platforms")
      platforms=()
      shift 1
      ;;
    "--platform")
      platforms+=( "${2}" )
      shift 2
      ;;
    "--reset_arches")
      arches=()
      shift 1
      ;;
    "--arch")
      arches+=( "${2}" )
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ ${#tools[@]} > 0 ]] || usage_error "Expected at least one tool to be specified."
[[ ${#platforms[@]} > 0 ]] || usage_error "Expected at least one platform to be specified."
[[ ${#arches[@]} > 0 ]] || usage_error "Expected at least one arch to be specified."

[[ ${#args[@]} > 0 ]] && release_tag="${args[0]}"


# MARK - Query for buildtool release info

# Switch to the workspace directory. We do this so that the GitHub CLI has 
# multiple avenues for authenticating. 
cd "${BUILD_WORKSPACE_DIRECTORY}"

# Determine which release to retrieve
release_query_suffix="latest"
[[ -n "${release_tag:-}" ]] && release_query_suffix="tags/${release_tag}"

# Execute the query
release_query_cmd=(gh api -X GET "repos/bazelbuild/buildtools/releases/${release_query_suffix}")
release_query_result="$( "${release_query_cmd[@]}" )"

# Get the release tag
release_tag="$( echo "${release_query_result}" | jq -r '.tag_name' )"

# Create a download directory
download_dir="$( mktemp -d )"
cleanup() {
  rm -rf "${download_dir}"
}
trap cleanup EXIT

# Output
if [[ "${verbose}" == true ]]; then
  echo >&2 "Release Tag: ${release_tag}"
  echo >&2 "Tools: $( join_by ", " "${tools[@]}" )"
  echo >&2 "Platforms: $( join_by ", " "${platforms[@]}" )"
  echo >&2 "Arches: $( join_by ", " "${arches[@]}" )"
fi

# Prepare asset filter regex
asset_regex='^('"$( IFS='|'; echo "${tools[*]}" )"')-'
asset_regex+='('"$( IFS='|'; echo "${platforms[*]}" )"')-'
asset_regex+='('"$( IFS='|'; echo "${arches[*]}" )"')'

# Download the assets and generate the sums.
asset_sha256_values=()
assets=( $(echo "${release_query_result}" | jq -r -c '.assets[] | @base64') )
for asset_base64_json in "${assets[@]}" ; do
  asset_json="$( echo ${asset_base64_json} | base64 --decode )"
  asset_name="$( echo "${asset_json}" | jq -r '.name' )"
  [[ "${asset_name}" =~ ${asset_regex} ]] || continue

  # Download the asset
  [[ "${verbose}" == true ]] && echo >&2 "Downloading ${asset_name}..."
  asset_url="$( echo "${asset_json}" | jq -r '.browser_download_url' )"
  download_path="${download_dir}/${asset_name}"
  curl -s -S -L -o "${download_path}" "${asset_url}"

  # Calcuate the SHA256
  asset_sha256="$( cat "${download_path}" | shasum -a 256 | awk '{print $1;}' )"
  [[ "${verbose}" == true ]] && echo >&2 "SHA256 for ${asset_name}: ${asset_sha256}"

  # Create the sha256_values entry; the '%.*' in asset_name expansion will strip the extension for the file.
  asset_key="$( echo "${asset_name%.*}" | sed -E -e 's/[-.]/_/g'  )"
  asset_sha256_values+=( "            \"${asset_key}\": \"${asset_sha256}\"," )
done

# Combine the entries into a newline delimited string
asset_sha256_values_str="$( join_by $'\n' "${asset_sha256_values[@]}" )"

# Create comma separated list
tools_str="$( join_by ", " $(double_quote_items "${tools[@]}") )"
platforms_str="$( join_by ", " $(double_quote_items "${platforms[@]}") )"
arches_str="$( join_by ", " $(double_quote_items "${arches[@]}") )"

# Create the declaration
assets_declaration="$(cat <<-EOF
load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains", "buildtools_assets")

buildifier_prebuilt_register_toolchains(
    assets = buildtools_assets(
        version = "${release_tag}",
        names = [${tools_str}],
        platforms = [${platforms_str}],
        arches = [${arches_str}],
        sha256_values = {
${asset_sha256_values_str}
        },
    ),
)
EOF
)"

echo "${assets_declaration}"
