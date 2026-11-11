{ pkgs, ... }:

{
	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
	};

	hardware.graphics.enable = true;

	security.polkit.enable = true;

	xdg.portal = {
		enable = true;

		extraPortals = [
			pkgs.xdg-desktop-portal-gtk
		];

		config.hyprland = {
			default = [ "hyprland" "gtk" ];
			"org.freedesktop.impl.portal.FileChooser" = "gtk";
		};
	};
}
