#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

set -euo pipefail
pr="${1?usage: $0 <RFC number>}"
curl -fsSL "https://api.github.com/repos/nixos/rfcs/issues/$pr/comments?per_page=100" | jq -rf nominations.jq
curl -fsSL "https://api.github.com/repos/nixos/rfcs/pulls/$pr/comments?per_page=100" | jq -rf nominations.jq
