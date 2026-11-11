{ config, ... }:

{
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
}
