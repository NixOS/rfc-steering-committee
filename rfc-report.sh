#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq hub

set -euo pipefail
IFS= read -rp "Last meeting was (default '2 weeks ago', example '2022-12-14')? " last_meeting >&2
export LAST_MEETING=$(date -I -d "${last_meeting:-2 weeks ago}")

cat <<EOF
## General business

Present in the meeting:

Agenda for today:
EOF

hub --paginate api "repos/nixos/rfcs/pulls?per_page=100" | jq -rf ./rfc-report.jq

cat <<EOF
## Discussion points

## Leader of next meeting
<!-- rotation: @edolstra, @lheckemann, @kevincox, @tomberek -->
REPLACE will lead the next meeting on YYYY-MM-DD

https://pad.mayflower.de/nixos-rfc-steering-committee
EOF
