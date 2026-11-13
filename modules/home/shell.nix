{ ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';

    shellAbbrs = {
        nro = "sudo nixos-rebuild switch --flake ~/.nixdots#oolong";
    };

    shellAliases = {
      ll = "ls -la";
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
