{ config, ... }:

let
	bin = "/run/current-system/sw/bin";
	dpms = state: "${bin}/hyprctl dispatch 'hl.dsp.dpms({ action = \"${state}\" })'";
in
{
	services.hypridle = {
		enable = true;
		settings = {
			general = {
				lock_cmd = "${config.home.profileDirectory}/bin/lock-screen";
				before_sleep_cmd = "${bin}/loginctl lock-session";
				after_sleep_cmd = dpms "on";
			};

			listener = [
				{
					timeout = 300;
					on-timeout = "${bin}/loginctl lock-session";
				}
				{
					timeout = 330;
					on-timeout = dpms "off";
					on-resume = dpms "on";
				}
			];
		};
	};
}
