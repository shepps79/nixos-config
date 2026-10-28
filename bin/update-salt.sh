#!/usr/bin/env bash
# Update flake inputs, then build and switch the salt configuration.
set -euo pipefail
exec "$(dirname "$(readlink -f "$0")")/update" salt
