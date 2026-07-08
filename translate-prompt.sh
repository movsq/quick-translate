#!/usr/bin/env bash
# Runs INSIDE the kitty popup opened by translate-input.sh.
# Prompts for text, translates it (languages per translator.conf), and offers
# to copy the result — the input-mode counterpart of translate-view.sh.
set -u

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/load-config.sh"

bold=$(tput bold) dim=$(tput dim) reset=$(tput sgr0)
hr() { printf '%s%s%s\n' "$dim" "────────────────────────────────────────" "$reset"; }

printf '%sText to translate (%s)%s\n' "$bold" "$TRANS_LABEL" "$reset"
hr
IFS= read -r text

if [ -z "${text//[[:space:]]/}" ]; then
    printf '%sNothing entered.%s\n' "$dim" "$reset"
    sleep 0.6
    exit 0
fi

printf '\n%sTranslation (%s)%s\n' "$bold" "$TRANS_LABEL" "$reset"
hr
printf '%sTranslating…%s' "$dim" "$reset"

translation="$(trans -b "$TRANS_SPEC" "$text" 2>/dev/null)"
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
