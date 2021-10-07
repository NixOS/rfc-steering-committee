#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

set -euo pipefail
export CLOSED_SINCE=$(date -I -d "2 weeks ago")

cat <<EOF
## General business

Present in the meeting:

Agenda for today:
EOF

curl -fsSL "https://api.github.com/repos/nixos/rfcs/pulls?per_page=100" | jq -rf ./rfc-report.jq

cat <<EOF
## Discussion points

## Leader of next meeting
<!-- rotation: @edolstra, @Mic92, @spacekookie, @lheckemann, @kloenk -->
REPLACE will lead the next meeting on YYYY-MM-DD

pad.mayflower.de/nixos-rfc-steering-committee
EOF
