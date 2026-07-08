#!/usr/bin/env bash
# Runs INSIDE the kitty popup opened by translate-popup.sh.
# Usage: translate-view.sh <file-with-original-text>
set -u

TARGET_LANG="cs"
tmpfile="${1:?usage: translate-view.sh <textfile>}"
text="$(cat "$tmpfile")"
rm -f "$tmpfile"

bold=$(tput bold) dim=$(tput dim) reset=$(tput sgr0)
hr() { printf '%s%s%s\n' "$dim" "────────────────────────────────────────" "$reset"; }

printf '%sOriginal%s\n' "$bold" "$reset"
hr
printf '%s\n\n' "$text"

printf '%sTranslation (→ %s)%s\n' "$bold" "$TARGET_LANG" "$reset"
hr
printf '%sTranslating…%s' "$dim" "$reset"

translation="$(trans -b ":$TARGET_LANG" "$text" 2>/dev/null)"
printf '\r\033[K'   # erase the "Translating…" line

if [ -z "$translation" ]; then
    printf 'Translation failed (no network, or rate-limited by Google).\n'
else
    printf '%s\n' "$translation"
fi

printf '\n%s[c] copy translation   [any other key] close%s\n' "$dim" "$reset"
IFS= read -r -n1 -s key
if [ "${key:-}" = "c" ] && [ -n "$translation" ]; then
    printf '%s' "$translation" | wl-copy
    printf 'Copied to clipboard.\n'
    sleep 0.6
fi
