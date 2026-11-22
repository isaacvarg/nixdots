{ config, lib, pkgs, ... }:

let
  home = config.home.homeDirectory;

  # Read live from the repo, so template edits apply on the next
  # wallpaper change without a rebuild.
  templates = "${home}/.nixdots/modules/home/skwd-wall/templates";
  wallpapers = "${home}/pictures/wallpapers";

  # skwd-walld renders each template on every wallpaper change, then runs
  # `reload` with sh -c. A bare output name lands in ~/.cache/skwd-wall-v2/.
  integrations = [
    {
      name = "quickshell";
      template = "${templates}/quickshell-colors.json";
      output = "quickshell-colors.json";
    }
    {
      # Included by terminal.nix; SIGUSR2 makes ghostty reload its config.
      name = "ghostty";
      template = "${templates}/ghostty.conf";
      output = "ghostty.conf";
      reload = "${pkgs.procps}/bin/pkill -USR2 ghostty || true";
    }
    {
      # Yazi has no HM config here, so skwd owns theme.toml outright.
      # Picked up the next time yazi starts.
      name = "yazi";
      template = "${templates}/yazi-theme.toml";
      output = "~/.config/yazi/theme.toml";
    }
    {
      # btop.nix sets color_theme = "skwd"; SIGUSR2 reloads a running btop.
      name = "btop";
      template = "${templates}/btop.theme";
      output = "~/.config/btop/themes/skwd.theme";
      reload = "${pkgs.procps}/bin/pkill -USR2 btop || true";
    }
  ];

  integrationsFile = pkgs.writeText "skwd-integrations.json" (builtins.toJSON integrations);
in
{
  # skwd-wall rewrites config.json itself, so Nix owns two keys instead of
  # the file: the wallpaper folder is kept in library.folders (other
  # folders added in the app stay), and the integrations list is replaced
  # whole. See docs/structure-reference.md.
  home.activation.skwdWallConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="${config.xdg.configHome}/skwd-wall-v2/config.json"
    jq=${lib.getExe pkgs.jq}
    args=(--arg dir "${wallpapers}" --slurpfile int "${integrationsFile}")
    check='any((.library.folders // [])[]; . == $dir) and .integrations == $int[0]'
    apply='.library.folders = ((.library.folders // []) | if any(.[]; . == $dir) then . else . + [$dir] end)
      | .integrations = $int[0]'

    if [ -s "$cfg" ] && ! $jq -e . "$cfg" >/dev/null 2>&1; then
      echo "skwd-wall: $cfg is not valid JSON, leaving it alone" >&2
    elif [ -s "$cfg" ] && $jq -e "''${args[@]}" "$check" "$cfg" >/dev/null; then
      : # already correct; don't touch the file skwd-walld is watching
    elif [[ ! -v DRY_RUN ]]; then
      mkdir -p "$(dirname "$cfg")"
      [ -s "$cfg" ] || echo '{}' > "$cfg"
      # config.json holds the Steam API key: keep its mode on the new file
      (umask 077; $jq "''${args[@]}" "$apply" "$cfg" > "$cfg.tmp")
      chmod --reference="$cfg" "$cfg.tmp"
      mv "$cfg.tmp" "$cfg"
    fi
  '';
}
