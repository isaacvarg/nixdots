{ pkgs, ... }:

let
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [ grim slurp wl-clipboard coreutils ];
    text = ''
      dir="$HOME/captures/screenshots"
      mkdir -p "$dir"

      # escape by rightclick or esc
      geometry="$(slurp)" || exit 0

      file="$dir/$(date +%F_%H-%M-%S).png"
      grim -g "$geometry" "$file"
      wl-copy --type image/png < "$file"
    '';
  };
in
{
  home.packages = [
    screenshot
    pkgs.wl-clipboard
  ];
}
