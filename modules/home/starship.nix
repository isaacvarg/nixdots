{ lib, ... }:

let
  glyph = code: builtins.fromJSON ''"\u${code}"'';

  capL = glyph "e0b6"; # nf-ple-left_half_circle_thick
  capR = glyph "e0b4"; # nf-ple-right_half_circle_thick

  pill = content: style: "[${capL}](fg:overlay)[${content}](${style})[${capR}](fg:overlay)";

  langSegment = symbol: {
    inherit symbol;
    disabled = false;
    style = "bg:overlay fg:pine";
    format = " ${pill " $symbol$version " "$style"}";
  };
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = lib.concatStrings [
        "$username"
        "$directory"
        "$git_branch"
        "$git_status"
        "$fill"
        "$c"
        "$elixir"
        "$elm"
        "$golang"
        "$haskell"
        "$java"
        "$julia"
        "$nodejs"
        "$nim"
        "$rust"
        "$scala"
        "$conda"
        "$python"
        "$time"
        "\n  "
        "[󱞪](fg:iris) "
      ];

      palette = "rose-pine-moon";

      palettes.rose-pine-moon = {
        overlay = "#393552";
        love = "#eb6f92";
        gold = "#f6c177";
        rose = "#ea9a97";
        pine = "#3e8fb0";
        foam = "#9ccfd8";
        iris = "#c4a7e7";
      };

      directory = {
        format = "[░▒▓](fg:overlay)[ $path ]($style)[${capR}](fg:overlay) ";
        style = "bg:overlay fg:pine";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          documents = "󰈙";
          downloads = "${glyph "f019"} "; # nf-fa-download
          music = "${glyph "f001"} "; # nf-fa-music
          pictures = "${glyph "f03e"} "; # nf-fa-image
        };
      };

      fill = {
        style = "fg:overlay";
        symbol = " ";
      };

      git_branch = {
        format = "${pill " $symbol $branch " "$style"} ";
        style = "bg:overlay fg:foam";
        symbol = glyph "e0a0"; # nf-pl-branch
      };

      git_status = {
        disabled = false;
        style = "bg:overlay fg:love";
        format = "[${capL}](fg:overlay)([$all_status$ahead_behind]($style))[${capR}](fg:overlay) ";
        up_to_date = "[ ✓ ](bg:overlay fg:iris)";
        untracked = ''[?\($count\)](bg:overlay fg:gold)'';
        stashed = ''[\$](bg:overlay fg:iris)'';
        modified = ''[!\($count\)](bg:overlay fg:gold)'';
        renamed = ''[»\($count\)](bg:overlay fg:iris)'';
        deleted = ''[✘\($count\)]($style)'';
        staged = ''[++\($count\)](bg:overlay fg:gold)'';
        ahead = ''[⇡\(''${count}\)](bg:overlay fg:foam)'';
        behind = ''[⇣\(''${count}\)](bg:overlay fg:rose)'';
        diverged = ''⇕[\[](bg:overlay fg:iris)[⇡\(''${ahead_count}\)](bg:overlay fg:foam)[⇣\(''${behind_count}\)](bg:overlay fg:rose)[\]](bg:overlay fg:iris)'';
      };

      time = {
        disabled = false;
        format = " ${pill " $time ${glyph "f017"} " "$style"}"; # nf-fa-clock_o
        style = "bg:overlay fg:rose";
        time_format = "%I:%M%P";
        use_12hr = true;
      };

      username = {
        disabled = false;
        format = "${pill " ${glyph "ec15"} " "$style"} "; # nf-cod-coffee 
        show_always = true;
        style_root = "bg:overlay fg:iris";
        style_user = "bg:overlay fg:iris";
      };

      golang = langSegment "${glyph "e627"} "; # nf-seti-go
      java = langSegment "${glyph "e738"} "; # nf-dev-java
      nodejs = langSegment "󰎙 ";
      rust = langSegment "${glyph "e7a8"} "; # nf-dev-rust
      python = langSegment "${glyph "e73c"} "; # nf-dev-python
    };
  };
}
