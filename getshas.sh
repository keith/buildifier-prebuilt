#!/bin/bash

set -euo pipefail

readonly version="$1"

for binary in buildifier buildozer; do
  for os in darwin linux; do
    for arch in amd64 arm64; do
      filename=$binary-$os-$arch
      url=https://github.com/bazelbuild/buildtools/releases/download/$version/$filename
      bin=$(mktemp)
      curl --fail --silent -L "$url" -o "$bin"
      sha=$(sha256sum "$bin" | cut -d ' ' -f 1)
      echo "\"${binary}_${os}_${arch}\": \"$sha\","
    done
  done
done
