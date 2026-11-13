{ ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';

    shellAbbrs = {
        # this works because our host match
        # the config names so we can ommit the
        # ~/.nixdots#system
        nrs = "sudo nixos-rebuild switch --flake ~/.nixdots";
        # i swear im not that lazy its muscle memory
        lg = "lazygit";
    };

    shellAliases = {
      ll = "ls -la";
      ff = "clear & fastfetch";
    };
  };

  # bash as a fallback
  programs.bash.enable = true;
  
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
}
