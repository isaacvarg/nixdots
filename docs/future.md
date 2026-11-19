# Future work

Ideas that are worked out but not built yet. Each section says what to add and why it isn't in the repo today.

## skwd-wall wallpaper folder

For now the wallpaper folder is set by hand in skwd-wall under Settings, once per machine. This section describes how to set it from Nix instead.

### Why it needs setting

skwd-wall keeps its settings in `~/.config/skwd-wall-v2/config.json`. The key `paths.wallpaper` holds the image folder, and videos use the same folder unless `paths.videoWallpaper` is set. When `paths.wallpaper` is empty, skwd-wall picks a default in this order.

1. `~/Pictures/Wallpapers`, if that folder exists.
2. The XDG pictures folder plus `Wallpapers`, with a capital W.
3. `~/Pictures/Wallpapers` again, if there is no XDG pictures folder.

The wallpapers live in `~/pictures/wallpapers`, all lowercase, and there is no `user-dirs.dirs`. The default therefore points at a folder that doesn't exist, because Linux paths are case-sensitive. Setting `xdg.userDirs.pictures` to `~/pictures` would not fix it either, since skwd-wall would then look for `~/pictures/Wallpapers`.

This comes from `crates/skwd-config/src/settings.rs` and `environment.rs` in liixini/skwd-deck, checked against skwd-wall 1.0.0-beta.29. Check them again before building this, in case the key name or the default changed.

### Why not let Home Manager own config.json

skwd-wall writes every settings change back to `config.json`. A Home Manager file is a read-only link into the Nix store, so saving from the app would fail. A writable symlink into this repo, the way `quickshell.nix` does it, would put every setting in git, including the Steam Web API key.

### The plan

Add a Home Manager activation step that sets only `paths.wallpaper` and leaves the rest of the file to the app. Home Manager runs activation steps at the end of every switch, after it writes its own files. The step uses `jq`, a command-line JSON editor from nixpkgs, to read and change the one key.

Put it in `modules/home/skwd-wall.nix` and import that from `bundles/home/desktop.nix`, next to the other desktop modules.

```nix
{ lib, pkgs, ... }:

{
  # skwd-wall rewrites config.json itself, so set one key instead of
  # owning the file. See docs/future.md.
  home.activation.skwdWallpaperDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.config/skwd-wall-v2/config.json"
    want="~/pictures/wallpapers"
    jq=${pkgs.jq}/bin/jq

    if [ -s "$cfg" ]; then
      if ! current=$($jq -r '.paths.wallpaper // ""' "$cfg" 2>/dev/null); then
        echo "skwd-wall: $cfg is not valid JSON, leaving it alone" >&2
        current="$want"
      fi
    else
      current=""
    fi

    if [ "$current" != "$want" ] && [[ ! -v DRY_RUN ]]; then
      mkdir -p "$(dirname "$cfg")"
      [ -s "$cfg" ] || echo '{}' > "$cfg"
      $jq --arg dir "$want" '.paths.wallpaper = $dir' "$cfg" > "$cfg.tmp"
      mv "$cfg.tmp" "$cfg"
    fi
  '';
}
```

Each part of the script handles one case.

- `entryAfter [ "writeBoundary" ]` runs the step after Home Manager has written its files.
- `${pkgs.jq}` uses jq from the Nix store, so jq doesn't need to be installed.
- The script reads the current value first and writes only when it differs. Most switches read the file and change nothing, so a running `skwd-walld` sees no change.
- If `config.json` is not valid JSON, the script prints a warning and skips. A failing command would otherwise stop the rest of Home Manager's activation.
- If the file doesn't exist yet, as on a new machine, the script creates it with `{}` first.
- jq writes to `config.json.tmp`, and `mv` replaces the original in one step. The file is never half-written.
- `[[ ! -v DRY_RUN ]]` skips the write during a dry-run activation.
- `--arg dir` passes the path to jq as a string, so a path with spaces or quotes can't break the expression.
- skwd-wall expands the leading `~/` itself, so the value can stay `~/pictures/wallpapers`.

### Cost and trade-offs

The step starts one jq process on a file of a few kilobytes, which takes milliseconds. It runs on every switch.

Nix sets the value, but it doesn't lock it. A folder change made in the app lasts until the next switch, which puts `~/pictures/wallpapers` back. Every other setting, such as the Steam login, the API key and transitions, stays as the app saved it.

If the app saves at the same moment as a switch, one of the two writes can be lost. That needs both to happen within milliseconds of each other.

Use this pattern for this one key. If more skwd-wall settings ever need to come from Nix, reconsider instead of adding more keys here, because the step would then be editing a file the app treats as its own.

### Checking it

After a switch, this should print `~/pictures/wallpapers`.

```bash
jq -r '.paths.wallpaper' ~/.config/skwd-wall-v2/config.json
```

To confirm a switch leaves a correct file alone, note the modification time, switch again, and compare. The time should not change.

```bash
stat -c %y ~/.config/skwd-wall-v2/config.json
```
