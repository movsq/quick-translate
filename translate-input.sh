#!/usr/bin/env bash
# Input mode: open an empty floating terminal window (app_id trans-popup,
# floated by the for_window rule in the main Sway config; terminal set by
# open_terminal in load-config.sh) that waits for you to TYPE
# the text to translate. Nothing is read from the selection or clipboard —
# use this when there is no selection to grab (languages per translator.conf).
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/load-config.sh"

open_terminal "$SCRIPT_DIR/translate-prompt.sh"
