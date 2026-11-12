{ pkgs, ... }:

{
  home.packages = with pkgs; [
		fastfetch
		ripgrep
		bat
		fd
    lazygit
    hyprlauncher
  ];
}
