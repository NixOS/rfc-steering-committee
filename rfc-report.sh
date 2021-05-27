#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

set -exuo pipefail
export CLOSED_SINCE=$(date -I -d "2 weeks ago")
curl -fsSL "https://api.github.com/repos/nixos/rfcs/pulls?per_page=100" | jq -rf ./rfc-report.jq
