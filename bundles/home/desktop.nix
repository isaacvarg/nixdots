{ ... }:

{
  imports = [
    ../../modules/home/hyprland/hyprland.nix
		../../modules/home/terminal.nix
		../../modules/home/browser.nix
		../../modules/home/cursor.nix
		../../modules/home/polkit.nix
    ../../modules/home/quickshell/quickshell.nix
    ../../modules/home/wallpaper.nix
    ../../modules/home/xdg.nix
	];

  home.packages = with pkgs; [
    hyprlauncher
    discord
  ];
}
