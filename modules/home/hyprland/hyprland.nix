{ ... }:

{
	wayland.windowManager.hyprland = {
		enable = true;

		package = null;
		portalPackage = null;

		systemd.enable = false;
		configType = "lua";

		extraConfig = builtins.readFile ./hyprland.lua;
	};
}
