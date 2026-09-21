#!/usr/bin/env bash
# Build and switch the pepper configuration.
set -euo pipefail
exec "$(dirname "$(readlink -f "$0")")/rebuild" pepper
