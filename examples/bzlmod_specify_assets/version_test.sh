#!/usr/bin/env bash

if "$1" --version | grep -q "8.2.0"; then
  exit 0
fi

echo "error: unexpected version: $($1 --version)"
exit 1
