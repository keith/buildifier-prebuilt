#!/usr/bin/env bash

name="World"
[[ ${#} -gt 0 ]] && name="${1}"

echo "Hello, ${name}!"
