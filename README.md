# translator — selection → your language, on a keybind (Sway/Wayland)

Highlight text anywhere, hit a keybind, get a translation (Czech by default —
configurable, see [Configuration](#configuration)). The source language is
auto-detected by Google Translate by default, or can be pinned to a preset
one. Translation is done via
[translate-shell](https://github.com/soimort/translate-shell) (`trans -b`, the
free web endpoint — no API key). Reads the **primary selection**
(middle-click buffer) first and falls back to the regular clipboard if the
primary selection is empty. An empty selection just shows a "Nothing selected"
notification instead of erroring.

Built for Sway on EndeavourOS/Arch, with kitty as the terminal.

## Two modes

| Keybind | Mode | Script |
|---|---|---|
| `Super+T` | Notification popup, click it to copy | `translate-notify.sh` |
| `Super+Shift+T` | Floating kitty window, stays open | `translate-popup.sh` |

### Notification mode (`Super+T`) — quick single-word lookups

`translate-notify.sh` grabs the selection, translates it, and shows the result
as a corner notification (8 s timeout). **Clicking the notification copies the
translation to the clipboard** (`wl-copy`), confirmed by a short "Copied to
clipboard" toast. If you ignore or dismiss it, nothing is copied.

How the click works: `notify-send --action default=…` (needs libnotify ≥ 0.8)
blocks until the notification is clicked/dismissed/expired and prints the
invoked action's id; mako fires the `default` action on left-click. This is
daemon-specific — plain fire-and-forget `notify-send` can't capture clicks,
and on dunst you'd use `dunstify --action` instead.

### Terminal mode (`Super+Shift+T`) — longer text

`translate-popup.sh` grabs the selection, snapshots it to a temp file, and
opens `kitty --class trans-popup` running `translate-view.sh`, which shows the
original text and the translation. The window floats (via the Sway rule below)
and stays open until you press a key: **`c` copies the translation** to the
clipboard, any other key just closes the window.

## Dependencies

- `translate-shell` — the `trans` command
- `wl-clipboard` — `wl-paste` / `wl-copy`
- `kitty` — terminal for the popup mode
- **`mako`** — notification daemon. On this machine neither mako nor dunst was
  installed when this was set up (2026-07-08), so **mako was installed**
  (`pacman -S mako`) and is autostarted from the Sway config (see below). If
  you switch to dunst, notification mode's click-to-copy must be rewritten
  around `dunstify --action`.
- `libnotify` ≥ 0.8 — `notify-send` with `--action` support

```sh
pacman -S --needed translate-shell wl-clipboard kitty mako libnotify
```

## Sway config lines (IMPORTANT — live outside this repo!)

These lines are in the **main Sway config** (`~/.config/sway/config`), not in
this repo, so git does **not** capture them. On a fresh setup you must add
them manually. They must appear **after** `set $mod` is defined:

```
# ═══ TRANSLATOR (~/.config/sway/translator) — managed block, start ═══
# notification daemon (needed for notification mode + click-to-copy)
exec mako
# floating rule for the terminal-mode popup window
for_window [app_id="trans-popup"] floating enable, resize set 800 400, move position center
# notification mode: translate selection (per translator.conf), click notification to copy
bindsym $mod+t exec ~/.config/sway/translator/translate-notify.sh
# terminal mode: floating kitty window with original + translation
bindsym $mod+Shift+t exec ~/.config/sway/translator/translate-popup.sh
# ═══ TRANSLATOR — managed block, end ══════════════════════════════════
```

Then reload Sway (`Super+Shift+R` → `1` on this setup, or `swaymsg reload`).

## Configuration

Languages are configured in **`translator.conf`** (same directory as the
scripts, sourced as shell by both modes via `load-config.sh`). The file is
optional — without it the defaults below apply. Changes take effect on the
next keypress, no reload needed.

```sh
TARGET_LANG="cs"    # language to translate into (any `trans -list-codes` code)
AUTO_DETECT="on"    # "on" = Google detects the source; "off" = use SOURCE_LANG
SOURCE_LANG=""      # source language, only used when AUTO_DETECT="off"
```

Setting `AUTO_DETECT="off"` while leaving `SOURCE_LANG` empty shows a warning
notification and falls back to auto-detection. Full details and examples:
[docs/CONFIG.md](docs/CONFIG.md).

## Troubleshooting

- **No notification at all** → is mako running? `pgrep mako`; start with
  `swaymsg exec mako` or reload Sway.
- **"Translation failed"** → no network, or Google rate-limited the free
  endpoint; wait a bit. Test manually: `trans -b :cs "hello"` (use your
  configured `TARGET_LANG`).
- **Wrong language detected / wrong direction** → check `translator.conf`:
  either fix `TARGET_LANG`, or set `AUTO_DETECT="off"` with an explicit
  `SOURCE_LANG` (see [docs/CONFIG.md](docs/CONFIG.md)).
- **Popup window isn't floating** → the `for_window [app_id="trans-popup"]`
  rule is missing from the main Sway config (see above).
- **Wrong text translated** → primary selection was empty, so the clipboard
  fallback kicked in. Re-highlight the text.
