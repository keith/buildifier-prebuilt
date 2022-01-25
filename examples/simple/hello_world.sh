#!/usr/bin/env bash

name="World"
[[ ${#} > 0 ]] && name="${1}"

echo "Hello, ${name}!"

