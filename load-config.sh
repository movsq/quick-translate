# Sourced by translate-notify.sh and translate-view.sh — not run directly.
# Loads translator.conf (same directory, optional) over the built-in defaults
# and derives:
#   TRANS_SPEC  — the "source:target" argument for trans; empty source means
#                 Google auto-detects the language
#   TRANS_LABEL — human-readable direction for titles, e.g. "→ cs" / "en → cs"

TARGET_LANG="cs"
AUTO_DETECT="on"
SOURCE_LANG="en"

_conf="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/translator.conf"
[ -f "$_conf" ] && . "$_conf"

if [ "$AUTO_DETECT" = "off" ] && [ -z "$SOURCE_LANG" ]; then
    notify-send -a translator -u normal -t 4000 "Translator" \
        "AUTO_DETECT=\"off\" but SOURCE_LANG is empty in translator.conf — using auto-detect"
    AUTO_DETECT="on"
fi

if [ "$AUTO_DETECT" = "off" ]; then
    TRANS_SPEC="$SOURCE_LANG:$TARGET_LANG"
    TRANS_LABEL="$SOURCE_LANG → $TARGET_LANG"
else
    TRANS_SPEC=":$TARGET_LANG"
    TRANS_LABEL="→ $TARGET_LANG"
fi
