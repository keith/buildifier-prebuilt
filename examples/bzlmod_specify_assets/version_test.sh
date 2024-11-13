#!/usr/bin/env bash

if "$1" --version | grep -q "4.2.5"; then
  exit 0
fi
exit 1
