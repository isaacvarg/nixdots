{ config, lib, pkgs, ... }:

let
  jq = lib.getExe pkgs.jq;
  skwdCache = "${config.users.users.isaac.home}/.cache/skwd-wall-v2";

  settings = pkgs.writeText "dms-greeter-settings.json" (builtins.toJSON {
    currentThemeName = "dynamic";
    fontFamily = "JetBrainsMono Nerd Font";
    monoFontFamily = "JetBrainsMono Nerd Font";
  });
in
{
  services.displayManager.dux-greeter = {
    enable = true;
    compositor.name = "hyprland";
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  systemd.services.greetd.preStart = lib.mkBefore ''
    cd /var/lib/dms-greeter
    install -m 644 ${settings} settings.json

    mode=dark
    if [ -r ${skwdCache}/scheme.json ]; then
      mode=$(${jq} -r '.mode // "dark"' ${skwdCache}/scheme.json || echo dark)
      ${jq} '{colors: (.colors | {dark: map_values(.dark.color), light: map_values(.light.color)})}' \
        ${skwdCache}/scheme.json > colors.json.tmp \
        && mv colors.json.tmp colors.json || rm -f colors.json.tmp
    fi

    if [ -r ${skwdCache}/last-wallpaper.json ]; then
      ${jq} --arg mode "$mode" \
        '{wallpaperPath: (if .type == "static" then .path else .thumb end), isLightMode: ($mode == "light")}' \
        ${skwdCache}/last-wallpaper.json > session.json.tmp \
        && mv session.json.tmp session.json || rm -f session.json.tmp
    fi
  '';
}
