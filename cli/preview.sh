#!/bin/bash
#/cli/preview.sh
#
# Generates rendered previews, given a thread ID
#

NOTMUCH_THREAD_ID=$2

DEFAULT='\u001b[0m'
START='\u001b'
CYAN='[36m'

format_email() {
    local thread_id="$1"
    notmuch show --format=json --include-html "$thread_id" | jq -r '
    .[][][0] |
    "\u001b[36mFrom:\u001b[0m \(.headers.From)\n" +
    "\u001b[36mTo:\u001b[0m \(.headers.To)\n" +
    "\u001b[36mSubject:\u001b[0m \(.headers.Subject)\n" +
    "\u001b[36mDate:\u001b[0m \(.headers.Date)\n" +
    "\u001b[36mTags:\u001b[0m \(.tags | join(", "))\n" +
    "---\n\n" +
    "\(.body.[])"
    ' | fold -s -w 55
}

if [ ! -z "$NOTMUCH_THREAD_ID" ]; then
    format_email "$NOTMUCH_THREAD_ID"
fi
