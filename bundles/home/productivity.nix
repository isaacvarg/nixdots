{ pkgs, ... }:

{
  imports = [
    ../../modules/home/artcraft.nix
  ];

  home.packages = with pkgs; [
    obsidian
  ];
}
