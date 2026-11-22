{ pkgs, ... }:

let
  glyph = code: builtins.fromJSON ''"\u${code}"'';

  esc = glyph "001b";
  grey = text: "${esc}[90m${text}";

  header = title: {
    type = "custom";
    format = grey title;
  };
  footer = {
    type = "custom";
    format = grey "└────────────────────────────────────────────────────┘";
  };

  module = type: key: keyColor: extra: { inherit type key keyColor; } // extra;

  hw = "#f2cdcd";
  sw = "#fab387";
  de = "#b4befe";
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "kitty-direct";
        source = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";
        width = 30;
        height = 15;
        padding = {
          top = 5;
          right = 10;
        };
      };

      modules = [
        "break"
        (header "┌──────────────────────Hardware──────────────────────┐")
        (module "host" "${glyph "f108"} PC" hw { })
        (module "cpu" "│ ├${glyph "f4bc"}" hw { showPeCoreCount = true; })
        (module "gpu" "│ ├${glyph "f2db"}" hw { detectionMethod = "pci"; })
        (module "display" "│ ├󱄄" hw { })
        (module "disk" "│ ├󰋊" hw { })
        (module "memory" "│ ├${glyph "e266"}" hw { })
        footer
        "break"
        (header "┌──────────────────────Software──────────────────────┐")
        (module "os" "${glyph "f313"} OS" sw { })
        (module "kernel" "│ ├${glyph "f17c"}" sw { })
        (module "packages" "│ ├󰏖" sw { })
        (module "shell" "└ └${glyph "f489"}" sw { })
        "break"
        (module "de" "${glyph "f2d0"} DE" de { })
        (module "wm" "│ ├${glyph "f2d2"}" de { })
        (module "wmtheme" "│ ├󰉼" de { })
        (module "icons" "│ ├󰀻" de { })
        (module "cursor" "│ ├${glyph "f245"}" de { })
        (module "terminalfont" "│ ├${glyph "f031"}" de { })
        (module "terminal" "└ └${glyph "e795"}" de { })
        footer
        "break"
        (header "┌────────────────────Uptime / Age────────────────────┐")
        (module "command" "  ${glyph "f073"} OS Age " "magenta" {
          text = "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days";
        })
        (module "uptime" "  ${glyph "f017"} Uptime " "magenta" { })
        footer
        "break"
      ];
    };
  };
}
