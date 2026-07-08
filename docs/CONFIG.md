# Configuration — `translator.conf`

Both translation scripts (`translate-notify.sh`, `translate-view.sh`) read
`translator.conf` from the repo directory at startup, via the shared loader
`load-config.sh`. The file is plain shell (`KEY="value"`, `#` comments) and is
**optional** — if it's missing, the built-in defaults below apply. Changes
take effect on the next keypress; nothing needs reloading.

## Keys

| Key | Default | Meaning |
|---|---|---|
| `TARGET_LANG` | `"cs"` | Language to translate **into**. |
| `AUTO_DETECT` | `"on"` | `"on"`: Google auto-detects the source language. `"off"`: use `SOURCE_LANG`. |
| `SOURCE_LANG` | `""` | Source language, used **only** when `AUTO_DETECT="off"`. |

Language codes are anything `trans -list-codes` accepts (`cs`, `en`, `de`,
`ja`, …).

## Examples

Default behavior — auto-detect anything, translate to Czech:

```sh
TARGET_LANG="cs"
AUTO_DETECT="on"
SOURCE_LANG=""
```

Force English → German (useful when short words get misdetected):

```sh
TARGET_LANG="de"
AUTO_DETECT="off"
SOURCE_LANG="en"
```

## How it maps to `trans`

`load-config.sh` turns the config into the `trans` language-pair argument:
`AUTO_DETECT="on"` gives `trans -b :TARGET`, `"off"` gives
`trans -b SOURCE:TARGET`. It also builds the direction label shown in the
notification title and the popup header (`→ cs` vs `en → cs`).

## Edge cases

- `AUTO_DETECT="off"` with an empty `SOURCE_LANG` is a config error: the
  scripts show a warning notification and fall back to auto-detection rather
  than failing.
- The file is sourced as shell, so keep values quoted and don't put commands
  in it.
