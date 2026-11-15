{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts               
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      nunito
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Symbols Nerd Font" ];
      serif     = [ "Noto Serif" "Symbols Nerd Font" ];
      monospace = [ "JetBrainsMono Nerd Font" "Symbols Nerd Font Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
