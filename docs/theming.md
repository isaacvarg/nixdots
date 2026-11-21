# Theming

Apps take their colours from the current wallpaper. skwd-wall picks the colours, renders a template for each app, and the app loads the result. Nix sets up which apps take part; skwd does the rendering at runtime, so a new wallpaper recolours everything without a rebuild.

## How it works

```
pick a wallpaper (Super+W)
  → skwd-walld extracts a Material You scheme
  → for each entry in config.json "integrations":
       read the template, fill in {{colors...}} tokens, write the output
       run the entry's reload command, if it has one
  → each app reads its output file
```

Files involved:

| File | Role |
| --- | --- |
| `modules/home/skwd-wall/skwd-wall.nix` | The list of integrations, and the activation step that writes them into skwd's config |
| `modules/home/skwd-wall/templates/` | One template per app |
| `~/.config/skwd-wall-v2/config.json` | skwd's own settings file. Nix owns only `integrations` and the wallpaper entry in `library.folders` |
| `~/.cache/skwd-wall-v2/` | Where outputs go when an entry's `output` is a bare file name |
| `~/.config/skwd-wall-v2/matugen/templates/` | skwd's stock templates, kept as a reference. Copy from here, don't edit here |

Apps themed today:

| App | Output | How it loads |
| --- | --- | --- |
| quickshell | `~/.cache/skwd-wall-v2/quickshell-colors.json` | `Theme.qml` watches the file and recolours live |
| ghostty | `~/.cache/skwd-wall-v2/ghostty.conf` | `config-file` in `terminal.nix`; `pkill -USR2 ghostty` reloads open windows |
| yazi | `~/.config/yazi/theme.toml` | Read the next time yazi starts |

## Adding an app

Each app needs three things: a template, an entry in `skwd-wall.nix`, and a way for the app to load the output.

### 1. Write the template

Start from skwd's stock template if there is one:

```bash
ls ~/.config/skwd-wall-v2/matugen/templates/
```

```bash
cp ~/.config/skwd-wall-v2/matugen/templates/btop.theme ~/.nixdots/modules/home/skwd-wall/templates/
```

If there isn't one, take the app's own theme file and replace each colour with a token (see [Template tokens](#template-tokens)). Read the stock template before you use it: some set things beyond colour, like the opacity line removed from the ghostty one.

### 2. Add the entry

Add an attribute set to the `integrations` list in `modules/home/skwd-wall/skwd-wall.nix`:

```nix
{
  name = "btop";
  template = "${templates}/btop.theme";
  output = "~/.config/btop/themes/skwd.theme";
  reload = "${pkgs.procps}/bin/pkill -USR2 btop || true";
}
```

| Field | Meaning |
| --- | --- |
| `name` | A label. Use the app's name. If it matches one of skwd's built-in app themes (foot, nvim, fish, kitty, btop, ghostty, niri, rofi, waybar), skwd stops offering its own setup for that app, which is what you want |
| `template` | Path to the template. Always `${templates}/<file>`, so it's read from the repo checkout |
| `output` | A bare file name goes in `~/.cache/skwd-wall-v2/`. A path with a `/` goes there; `~/` is expanded |
| `reload` | Optional. Run with `sh -c` after rendering. Use a full store path (`${pkgs.procps}/bin/pkill`) because skwd-walld's service `PATH` holds only coreutils, findutils, grep, sed, systemd and skwd's own tools. End it with `\|\| true` so an app that isn't running doesn't count as a failure |

### 3. Make the app load the output

Choose the output location by who owns the app's config:

- **Home Manager manages the app's config** (like ghostty): render into the cache with a bare file name, and have Nix point the app at it, through an include line or a theme setting. Never render into a file Home Manager writes, because that file is a read-only link into the Nix store.
- **Nothing manages the app's config** (like yazi): render straight into the file the app reads. skwd creates the folder if needed. If you later add a Home Manager module for the app, switch to the cache-and-include approach.

For an include line, make it optional where the app supports that, so a fresh machine doesn't error before the first render. Ghostty's `?` prefix does this.

For reloading, check whether the app reloads on a signal (ghostty, kitty and btop do), watches its config, or only reads it at startup. If it only reads at startup, leave `reload` out.

### 4. Switch and test

```bash
sudo nixos-rebuild switch --flake ~/.nixdots#latte
```

Then pick a wallpaper with Super+W and check the output. Any `{{` still in it means a token didn't resolve:

```bash
grep -n '{{' ~/.config/btop/themes/skwd.theme
```

After the first switch, template edits need no rebuild. Save the template, pick a wallpaper, and the new output appears. Rebuild only when you change `skwd-wall.nix` itself.

### Worked example: btop

btop isn't in the repo yet. To add it themed:

1. Copy the stock template as in step 1.
2. Add the `btop` entry from step 2.
3. Point btop at the theme. btop looks up themes by name in `~/.config/btop/themes/`, so `skwd.theme` is called `skwd`. In a Home Manager module:

   ```nix
   programs.btop = {
     enable = true;
     settings.color_theme = "skwd";
   };
   ```

4. Switch, pick a wallpaper, open btop.

btop reloads its theme on SIGUSR2, so the `reload` line recolours a running btop too.

## Template tokens

Tokens look like `{{colors.<role>.default.<format>}}`. Keep the middle part as `default`; skwd fills in the dark or light variant to match the wallpaper.

**Roles** are Material You colour roles. The common ones:

| Use | Roles |
| --- | --- |
| Accent | `primary`, `on_primary`, `primary_container`, `on_primary_container` |
| Second and third accents | `secondary`, `tertiary`, and their `on_` and `_container` versions |
| Backgrounds, darkest to lightest | `surface_container_lowest`, `surface`, `surface_container_low`, `surface_container`, `surface_container_high`, `surface_container_highest`, `surface_bright` |
| Text | `on_surface`, `on_surface_variant` (muted) |
| Lines and borders | `outline`, `outline_variant` |
| Errors | `error`, `on_error`, `error_container` |

`~/.cache/skwd-wall-v2/scheme.json` lists every role for the current wallpaper.

**Terminal colours.** `ansi_red`, `ansi_green`, `ansi_yellow`, `ansi_blue`, `ansi_magenta`, `ansi_cyan` and their `_bright` versions are real hues tinted towards the wallpaper. Use them for anything where red must look like red, such as terminal palettes, diffs and git status. The Material roles alone would make green and blue both look like the accent.

**Base16.** `{{base16.base00.hex}}` through `base0F` are there for apps that ship base16 themes.

**Formats:**

| Format | Example output |
| --- | --- |
| `hex` | `#ffb0c9` |
| `hex_stripped` | `ffb0c9` |
| `rgb` | `rgb(255, 176, 201)` |
| `rgba` | `rgba(255, 176, 201, 1.0)` |
| `red`, `green`, `blue` | `255` (one channel) |

## Quickshell colours

Widgets use only the semantic roles in `Theme.qml` (`accent`, `fg`, `chipBg` and so on), never raw colours. To give a role a new wallpaper colour:

1. Add a key to `templates/quickshell-colors.json`, for example `"tertiary": "{{colors.tertiary.default.hex}}"`.
2. Add a matching property to the `JsonAdapter` in `Theme.qml`, with a Catppuccin fallback: `property string tertiary: root.peach`.
3. Point the role at it: `readonly property color highlight: wall.tertiary`.

The fallback is what the bar shows on a machine where skwd hasn't rendered yet, or if the file is broken. `good` and `warn` stay fixed on purpose: status colours should mean the same thing on every wallpaper.

Quickshell's config is a live symlink, so these edits apply as soon as you save.

## Rules

- **Add integrations in Nix, not in skwd's settings.** The activation step replaces the whole `integrations` list on every switch, so entries added in the app are lost.
- **Don't use skwd's Settings > App themes.** It refuses configs that are links into the Nix store, and it would add a second include beside ours.
- **Leave the rest of `config.json` to skwd.** Nix owns two keys there because the app treats the file as its own. A third needs a good reason.

## Troubleshooting

skwd-walld logs each render:

```bash
grep 'static templates' ~/.cache/skwd-wall-v2/skwd-walld.log | tail
```

- `rendered N integration file(s)`: N should match the number of entries.
- `template not found: <path>`: the template path is wrong, or the file isn't in the checkout.
- `write <path> failed`: the output folder isn't writable, often because the output points at a Home Manager-managed file.

To see the list skwd is actually using:

```bash
nix run nixpkgs#jq -- .integrations ~/.config/skwd-wall-v2/config.json
```

If it doesn't match `skwd-wall.nix`, the switch didn't run the activation step, or `config.json` wasn't valid JSON. The switch output then says `skwd-wall: ... is not valid JSON, leaving it alone`.

Behaviour described here is from liixini/skwd-deck (`theme/integrations.rs`, `static_templates/renderer.rs`, `theme/apps/`), checked against 1.0.0-beta.29. Check it again after `nix flake update skwd-wall` if something stops rendering.
