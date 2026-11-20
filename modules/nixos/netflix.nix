{ pkgs, ... }:

let
  chromium = pkgs.chromium.override { enableWideVine = true; };

  launcher = pkgs.writeShellScriptBin "netflix" ''
    exec ${chromium}/bin/chromium \
      --app=https://www.netflix.com \
      --start-fullscreen \
      --password-store=basic \
      --user-data-dir="$HOME/.local/share/netflix-app" \
      "$@"
  '';

  desktopItem = pkgs.makeDesktopItem {
    name = "netflix";
    desktopName = "Netflix";
    genericName = "Streaming";
    icon = "applications-multimedia";
    categories = [ "AudioVideo" "Video" ];
    exec = "${launcher}/bin/netflix";
  };
in
{
  environment.systemPackages = [ launcher desktopItem ];
}
