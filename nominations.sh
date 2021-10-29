#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq hub

set -exuo pipefail
pr="${1?usage: $0 <RFC number>}"
hub api --paginate "repos/nixos/rfcs/issues/$pr/comments?per_page=100" | jq -rf nominations.jq
hub api --paginate "repos/nixos/rfcs/pulls/$pr/comments?per_page=100" | jq -rf nominations.jq
