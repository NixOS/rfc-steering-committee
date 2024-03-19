#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p github-cli python3

import datetime
import json
import os
import re
import subprocess
import sys

LABEL_IN_FCP = "status: FCP"
LABEL_IN_DISCUSSION = "status: in discussion"
LABEL_IN_NOMINATION = "status: open for nominations"

today = datetime.date.today()
last_meeting = today - datetime.timedelta(days=14)
try:
	print(f"Last meeting (default {last_meeting.strftime('%a')} {last_meeting}): ", end='', file=sys.stderr)
	last_meeting_string = input("")
	if last_meeting_string:
		year, month, day = last_meeting_string.split("-")
		last_meeting = datetime.date(year=int(year), month=int(month), day=int(day))
		print(f"Read last meeting as {last_meeting} ({last_meeting.strftime('%a')})", file=sys.stderr)
except: pass

def github_api(url):
	p = subprocess.run([
		"gh",
		"api",
		"--paginate",
		url
	],
		check=True,
		stdout=subprocess.PIPE)
	return json.loads(p.stdout.decode("UTF-8"))

def github_comments(pull):
	return github_api(f"repos/nixos/rfcs/issues/{pull['number']}/comments?per_page=100")

in_discussion = []
in_fcp = []
in_new = []
in_nomination = []

for pull in sorted(github_api("repos/nixos/rfcs/pulls?per_page=100"), key=lambda pull: pull["number"]):
	state = pull["state"]
	labels = {label["name"] for label in pull["labels"]}
	title = pull["title"]
	if pull["draft"]:
		continue
	elif LABEL_IN_FCP in labels:
		in_fcp.append(pull)
	elif LABEL_IN_DISCUSSION in labels:
		in_discussion.append(pull)
	elif LABEL_IN_NOMINATION in labels:
		in_nomination.append(pull)
	else:
		in_new.append(pull)

# Produce an indentation of the specified depth.
def tab(depth=1):
	# Note: Use spaces because hedgedoc doesn't like 8-char indents so users with that tab size in their terminal will have collapsed lists.
	return " " * 4 * depth

MARKDOWN_NESTING_RE = re.compile(r"([\[])")
def nested_markdown(child):
	return MARKDOWN_NESTING_RE.sub(r"\\\1", child)

TITLE_RE = re.compile(r"^\[(RFC)? ?[0-9]+\]:?\s*", re.IGNORECASE)
def rfc_clean_title(pull):
	return f'RFC {pull["number"]}: {TITLE_RE.sub("", pull["title"]).strip()}'

def rfc_link(pull):
	return f"[{rfc_clean_title(pull)}]({pull['html_url']})"

def maybe_print_labels(pull, ignore):
	labels = [
		label["name"]
		for label in pull["labels"]
		if label["name"] != ignore
	]
	if not labels:
		return
	print(f"{tab()}- Labels: {', '.join(labels)}")

def maybe_print_updated(pull):
	updated = datetime.date.fromisoformat(pull["updated_at"].partition("T")[0])
	if updated < last_meeting:
		return
	print(f"{tab()}- Updated on {updated}")

NOMINATION_RE = re.compile("shep|nominat", re.IGNORECASE)
def print_nominations(pull):
	print(f"{tab()}- Nominations:")
	have_any = False
	for c in github_comments(pull):
		matches = []
		for line in c["body"].split("\n"):
			m = NOMINATION_RE.search(line)
			if not m:
				continue
			if m.end() + 100 < len(line):
				line = f"{line[:m.end() + 100]}…"
			if m.start() > 100:
				line = f"…{line[m.start() - 100]}"
			matches.append(line.strip())
		if not matches:
			continue
		have_any = True

		date = c["created_at"][:len("yyyy-mm-dd")]
		snippet = nested_markdown(matches[0])
		additional = "" if len(matches) == 1 else f" (and {len(matches) - 1} more)"
		print(f"{tab(2)}- {date} [{c['user']['login']}: {snippet}{additional}]({c['html_url']})")
	if not have_any:
		print(f"{tab(2)}- None")


print("## General business")
print()
print("Present in the meeting: ")
print()

print("## Unlabelled and New RFCs")
if not in_new:
	print("None")
for pull in in_new:
	print(f"- [ ] {rfc_link(pull)}")
	maybe_print_labels(pull, "")
print()

print("## RFCs Open for Nominations")
if not in_nomination:
	print("None")
for pull in in_nomination:
	print(f"- [ ] {rfc_link(pull)}")
	maybe_print_labels(pull, LABEL_IN_NOMINATION)
	maybe_print_updated(pull)
	print_nominations(pull)
print()

print("## RFCs in Discussion")
if not in_discussion:
	print("None")
for pull in in_discussion:
	print(f"- [ ] {rfc_link(pull)}")
	maybe_print_labels(pull, LABEL_IN_DISCUSSION)
	maybe_print_updated(pull)
print()

print("## RFCs in FCP")
if not in_fcp:
	print("None")
for pull in in_fcp:
	print(f"- [ ] {rfc_link(pull)}")
	maybe_print_labels(pull, LABEL_IN_FCP)
print()

print("## Leader of next meeting")
print(f"@TODO will lead the next meeting on {today + datetime.timedelta(days=14)}")
