#!/usr/bin/env bash
# Build the pepper configuration without switching.
set -euo pipefail
exec "$(dirname "$(readlink -f "$0")")/nix-build-check" pepper
