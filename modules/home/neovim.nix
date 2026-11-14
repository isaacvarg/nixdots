{ lazyvim, ... }:

{
	imports = [
		lazyvim.homeManagerModules.default
	];

	programs.lazyvim = {
		enable = true;

		plugins = {
			# Workaround: lazyvim-nix (since #115) names dev dirs `owner--repo`, so
			# lazy.nvim can't map `require("trouble")` back to trouble.nvim and never
			# loads/configures it. LazyVim's lualine statusline then crashes on startup.
			# Force trouble to load before lualine. Remove once fixed upstream.
			lualine-trouble-fix = ''
				return {
					"nvim-lualine/lualine.nvim",
					dependencies = { "folke/trouble.nvim" },
				}
			'';
		};
	};
}
