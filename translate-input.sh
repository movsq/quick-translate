#!/usr/bin/env bash
# Input mode: open an empty floating kitty window (app_id trans-popup, floated
# by the for_window rule in the main Sway config) that waits for you to TYPE
# the text to translate. Nothing is read from the selection or clipboard —
# use this when there is no selection to grab (languages per translator.conf).
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec kitty --class trans-popup --title "Translator" \
    "$SCRIPT_DIR/translate-prompt.sh"
