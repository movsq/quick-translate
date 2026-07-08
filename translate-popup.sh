#!/usr/bin/env bash
# Terminal mode: grab the current selection and open a floating terminal
# window (app_id trans-popup, floated by a for_window rule in the main Sway
# config; terminal set by open_terminal in load-config.sh)
# showing the original text and its translation (languages per translator.conf).
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/load-config.sh"
APP_NAME="translator"

# Primary selection first, clipboard as fallback.
text="$(wl-paste -p --no-newline 2>/dev/null)"
if [ -z "${text//[[:space:]]/}" ]; then
    text="$(wl-paste --no-newline 2>/dev/null)"
fi
if [ -z "${text//[[:space:]]/}" ]; then
    "$NOTIFY" -a "$APP_NAME" -u low -t 3000 "Translator" "Nothing selected"
    exit 0
fi

# Snapshot the selection to a temp file so it can't change between the
# keypress and the translation running inside the new window.
tmpfile="$(mktemp --tmpdir trans-popup.XXXXXX)"
printf '%s' "$text" > "$tmpfile"

open_terminal "$SCRIPT_DIR/translate-view.sh" "$tmpfile"
