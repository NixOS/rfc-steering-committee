def issue_item: "* [ ] [RFC " + (.number | tostring) + ": " + (.title | sub("\\[(RFC)? ?[0-9]+\\]?:? *"; "")) + "](" + .html_url + ")";
def issue_items: if isempty(.[]) then "None" else map(issue_item) | join("\n") end + "\n\n";
def has_label(l): .labels | any(.name == l);

.
  | ($ENV.CLOSED_SINCE // error("Define env var CLOSED_SINCE as the date to compare to")) as $closed_since
  | length as $length
  | if $length >= 100 then error("Too many PRs! Can't deal with paging yet :(") else . end
  | sort_by(.number)
  | [
    { title: "Draft RFCs", items: map(select(has_label("status: draft"))) },
    { title: "Unlabelled and New RFCs", items: map(select(isempty(.labels | .[]) or has_label("status: new"))) },
    { title: "RFCs Open for Nominations", items: map(select(has_label("status: open for nominations"))) },
    { title: "RFCs in Discussion", items: map(select(has_label("status: in discussion"))) },
    { title: "RFCs in FCP", items: map(select(has_label("status: FCP"))) },
    { title: "Accepted/Rejected/Closed", items: map(select(.closed_at > $closed_since)) }
  ]
  | map("## " + .title + "\n\n" + (.items | issue_items))
  | join("\n")
  | "<!-- " + ($length | tostring) + " PRs processed -->\n\n" + .
