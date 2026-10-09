#!/usr/bin/env bash
# Build the salt configuration without switching.
set -euo pipefail
exec "$(dirname "$(readlink -f "$0")")/nix-build-check" salt
