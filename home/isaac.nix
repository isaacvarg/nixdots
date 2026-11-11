{ pkgs, ... }:

{
	imports = [
		../modules/home/hyprland.nix
		../modules/home/terminal.nix
		../modules/home/browser.nix
		../modules/home/polkit.nix
		../modules/home/ssh.nix
		../modules/home/neovim.nix
    ../modules/home/mise.nix
    ../modules/home/git.nix
    ../modules/home/gh.nix
    ../modules/home/ai.nix
	];

	home.username = "isaac";
	home.homeDirectory = "/home/isaac";

	home.stateVersion = "26.05";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		fastfetch
		ripgrep
		bat
		fd
    lazygit
	];
}
