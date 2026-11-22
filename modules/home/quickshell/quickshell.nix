{ config, lib, pkgs, ... }:

let
	multimedia = pkgs.kdePackages.qtmultimedia;

	quickshell = pkgs.symlinkJoin {
		name = "quickshell-${pkgs.quickshell.version}";
		paths = [ pkgs.quickshell ];
		nativeBuildInputs = [ pkgs.makeWrapper ];
		postBuild = ''
			for bin in qs quickshell; do
				wrapProgram $out/bin/$bin \
					--prefix NIXPKGS_QT6_QML_IMPORT_PATH : ${multimedia}/lib/qt-6/qml \
					--prefix QT_PLUGIN_PATH : ${multimedia}/lib/qt-6/plugins
			done
		'';
		meta.mainProgram = "quickshell";
	};

	lockScreen = pkgs.writeShellScriptBin "lock-screen" ''
		exec ${lib.getExe quickshell} -n -d -p "${config.xdg.configHome}/quickshell/lock.qml"
	'';
in
{
	home.packages = [ pkgs.libnotify lockScreen ];

	programs.quickshell = {
		enable = true;
		package = quickshell;
		systemd.enable = true;
	};

  # symlink for now bc otherwise
  # we would have to rebuild every time we change
  # something...
	xdg.configFile."quickshell".source =
		config.lib.file.mkOutOfStoreSymlink
			"${config.home.homeDirectory}/.nixdots/modules/home/quickshell/config";
}
