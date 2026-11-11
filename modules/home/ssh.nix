{ config, ... }:

{
	programs.ssh = {
		enable = true;

		extraConfig = ''
			Host *
				IdentityAgent ${config.home.homeDirectory}/.1password/agent.sock
		'';
	};
}
