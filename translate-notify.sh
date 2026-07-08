#!/usr/bin/env bash
# Notification mode: translate the current selection to the configured target
# language (translator.conf) and show the result as a mako notification.
# Clicking the notification copies the translation to the clipboard.
set -u

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/load-config.sh"
APP_NAME="translator"

# Primary selection first, clipboard as fallback.
text="$(wl-paste -p --no-newline 2>/dev/null)"
if [ -z "${text//[[:space:]]/}" ]; then
    text="$(wl-paste --no-newline 2>/dev/null)"
fi
if [ -z "${text//[[:space:]]/}" ]; then
    notify-send -a "$APP_NAME" -u low -t 3000 "Translator" "Nothing selected"
    exit 0
fi

translation="$(trans -b "$TRANS_SPEC" "$text" 2>/dev/null)"
if [ -z "$translation" ]; then
    notify-send -a "$APP_NAME" -u critical "Translator" \
        "Translation failed (no network, or rate-limited by Google)"
    exit 1
fi

# -A makes notify-send block until the notification is clicked, dismissed, or
# expires; mako fires the "default" action on left-click and notify-send then
# prints its id ("default") to stdout.
clicked="$(notify-send -a "$APP_NAME" -t 8000 \
    -A default="Copy translation" \
    "$TRANS_LABEL" "$translation")"

if [ "$clicked" = "default" ]; then
    printf '%s' "$translation" | wl-copy
    notify-send -a "$APP_NAME" -u low -t 2000 "Translator" "Copied to clipboard"
fi
