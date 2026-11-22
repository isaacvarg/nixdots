{ pkgs, ... }:

{
  imports = [
    ../../modules/home/shell.nix
    ../../modules/home/starship.nix
    ../../modules/home/fastfetch.nix
    ../../modules/home/btop.nix
  ];

  home.packages = with pkgs; [
		ripgrep
		bat
		fd
    lazygit
    yazi
    ouch
  ];
}
