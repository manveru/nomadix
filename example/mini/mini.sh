#!/usr/bin/env bash

set -exuo pipefail

echo "$@"

$TREE /nix/store -L 1

env

hello
sleep 600
