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

    # ssh refuses a config file that isn't owned by you or by root. things like 
    # claude desktop  runs commands in a bubblewrap FHS env that maps only my 
    # uid, so files in /nix/store show up as owned by nobody, and ssh rejects
    # a symlink into the store. home-manager links the generated file as
    # ~/.ssh/config.hm instead, and the activation step below copies it to
    # ~/.ssh/config as a file you own. Each switch overwrites that copy, so
    # make changes in this module.
    home.file.".ssh/config".target = ".ssh/config.hm";

    home.activation.installSshConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -D -m600 ${config.home.file.".ssh/config".source} "$HOME/.ssh/config"
    '';

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
