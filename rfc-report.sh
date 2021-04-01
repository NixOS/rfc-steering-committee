#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

set -exuo pipefail
export CLOSED_SINCE=$(date -I -d "2 weeks ago")
curl -f "https://api.github.com/repos/nixos/rfcs/pulls" | jq -rf ./rfc-report.jq
