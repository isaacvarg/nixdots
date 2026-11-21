{ config, pkgs, ... }:

{
	home.packages = [ pkgs.libnotify ];

	programs.quickshell = {
		enable = true;
		systemd.enable = true;
	};

  # symlink for now bc otherwise 
  # we would have to rebuild every time we change
  # something... 
	xdg.configFile."quickshell".source =
		config.lib.file.mkOutOfStoreSymlink
			"${config.home.homeDirectory}/.nixdots/modules/home/quickshell/config";
}
