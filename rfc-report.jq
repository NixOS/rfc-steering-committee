def issue_item(last_meeting): "* [ ] [RFC " + (.number | tostring) + ": " + (.title | sub("\\[(RFC)? ?[0-9]+\\]?:? *"; "")) + "](" + .html_url + ")" + if .updated_at > last_meeting then " <!-- updated since last meeting -->" else "" end;
def issue_items(last_meeting): if isempty(.[]) then "None" else map(issue_item(last_meeting)) | join("\n") end + "\n\n";
def has_label(l): .labels | any(.name == l);

.
  | ($ENV.LAST_MEETING // error("Define env var LAST_MEETING as the timestamp to compare to")) as $last_meeting
  | length as $length
  | sort_by(.number)
  | [
    { title: "Draft RFCs", items: map(select(.draft)) }
  ] + (map(select(.draft | not)) | [
      { title: "Unlabelled and New RFCs", items: map(select(isempty(.labels | .[]) or has_label("status: new"))) },
      { title: "RFCs Open for Nominations", items: map(select(has_label("status: open for nominations"))) },
      { title: "RFCs in Discussion", items: map(select(has_label("status: in discussion"))) },
      { title: "RFCs in FCP", items: map(select(has_label("status: FCP"))) },
      { title: "Accepted/Rejected/Closed", items: map(select(.closed_at > $last_meeting)) }
  ])
  | map("## " + .title + "\n\n" + (.items | issue_items($last_meeting)))
  | join("\n")
  | "<!-- " + ($length | tostring) + " PRs processed -->\n\n" + .
