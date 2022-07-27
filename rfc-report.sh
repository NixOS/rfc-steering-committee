#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq hub

set -euo pipefail
export CLOSED_SINCE=$(date -I -d "2 weeks ago")

cat <<EOF
## General business

Present in the meeting:

Agenda for today:
EOF

hub --paginate api "repos/nixos/rfcs/pulls?per_page=100" | jq -rf ./rfc-report.jq

cat <<EOF
## Discussion points

## Leader of next meeting
<!-- rotation: @edolstra, @spacekookie, @lheckemann, @kevincox, @tomberek -->
REPLACE will lead the next meeting on YYYY-MM-DD

https://pad.mayflower.de/nixos-rfc-steering-committee
EOF
