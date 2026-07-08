#!/usr/bin/env bash
# Runs INSIDE the kitty popup opened by translate-popup.sh.
# Usage: translate-view.sh <file-with-original-text>
set -u

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/load-config.sh"
tmpfile="${1:?usage: translate-view.sh <textfile>}"
text="$(cat "$tmpfile")"
rm -f "$tmpfile"

bold=$(tput bold) dim=$(tput dim) reset=$(tput sgr0)
hr() { printf '%s%s%s\n' "$dim" "────────────────────────────────────────" "$reset"; }

# First pass shows the selection; pressing "n" loops back for typed input.
first=1
while true; do
    if [ "$first" = 1 ]; then
        first=0
    else
        clear
        printf '%sText to translate (%s)%s\n' "$bold" "$TRANS_LABEL" "$reset"
        hr
        IFS= read -r text
        if [ -z "${text//[[:space:]]/}" ]; then
            break
        fi
    fi

    printf '%sOriginal%s\n' "$bold" "$reset"
    hr
    printf '%s\n\n' "$text"

    printf '%sTranslation (%s)%s\n' "$bold" "$TRANS_LABEL" "$reset"
    hr
    printf '%sTranslating…%s' "$dim" "$reset"

    translation="$(trans -b "$TRANS_SPEC" "$text" 2>/dev/null)"
    printf '\r\033[K'   # erase the "Translating…" line

    if [ -z "$translation" ]; then
        printf 'Translation failed (no network, or rate-limited by Google).\n'
    else
        printf '%s\n' "$translation"
    fi

    printf '\n%s[c] copy   [n] next translation   [any other key] close%s\n' "$dim" "$reset"
    IFS= read -r -n1 -s key
    case "${key:-}" in
        c)
            if [ -n "$translation" ]; then
                printf '%s' "$translation" | wl-copy
                printf 'Copied to clipboard.\n'
                sleep 0.6
            fi
            break
            ;;
        n) continue ;;
        *) break ;;
    esac
done
