{ pkgs, ... }:

{
  imports = [
    ../../modules/home/shell.nix
    ../../modules/home/starship.nix
  ];

  home.packages = with pkgs; [
		fastfetch
		ripgrep
		bat
		fd
    lazygit
    hyprlauncher
  ];
}
