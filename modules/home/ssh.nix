{ config, lib, ... }:

let
  cfg = config.my.ssh;
in
{
  options.my.ssh.onePasswordKeys = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "Work NixOS" ];
    description = ''
      1Password SSH key item names the agent offers, in order. Set per machine
      so each one signs in with its own key. Empty means 1Password's default
      (every key in the Personal/Private vault).
    '';
  };

  config = {
    programs.ssh = {
      enable = true;

      extraConfig = ''
        Host *
          IdentityAgent ${config.home.homeDirectory}/.1password/agent.sock
      '';
    };

    home.sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
    };

    xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (cfg.onePasswordKeys != [ ]) {
      text = lib.concatMapStrings (item: ''
        [[ssh-keys]]
        item = "${item}"

      '') cfg.onePasswordKeys;
    };
  };
}
