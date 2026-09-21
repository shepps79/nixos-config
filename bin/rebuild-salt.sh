#!/usr/bin/env bash
# Build and switch the salt configuration.
set -euo pipefail
exec "$(dirname "$(readlink -f "$0")")/rebuild" salt
