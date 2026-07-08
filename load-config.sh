# Sourced by every script — not run directly.
# Loads translator.conf (same directory, optional) over the built-in defaults
# and derives:
#   TRANS_SPEC  — the "source:target" argument for trans; empty source means
#                 Google auto-detects the language
#   TRANS_LABEL — human-readable direction for titles, e.g. "→ cs" / "en → cs"

TARGET_LANG="cs"
AUTO_DETECT="on"
SOURCE_LANG="en"

# ── Swappable external tools ────────────────────────────────────────────
# Only these two are swappable; everything else the scripts call — the
# translate-shell `trans` command and the Wayland clipboard (`wl-paste` /
# `wl-copy`) — is a hard dependency and is not meant to be customized here.

# Notification command. Must speak notify-send's CLI (-a -u -t -A …); both
# mako and dunst ship a compatible notify-send. Override in translator.conf.
NOTIFY="notify-send"

# Terminal used for the floating popup + input windows. The window MUST get
# the Wayland app_id / X11 class "trans-popup" so the Sway for_window float
# rule matches it. This is a function (not a plain command) so it can absorb
# the flag differences between terminals — override it in translator.conf for
# foot, alacritty, etc. It receives the command to run as "$@".
open_terminal() {
    exec kitty --class trans-popup --title "Translator" "$@"
}

_conf="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/translator.conf"
[ -f "$_conf" ] && . "$_conf"

if [ "$AUTO_DETECT" = "off" ] && [ -z "$SOURCE_LANG" ]; then
    "$NOTIFY" -a translator -u normal -t 4000 "Translator" \
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
