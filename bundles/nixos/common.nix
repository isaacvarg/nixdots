{ ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  nixpkgs.config.allowUnfree = true;

  # every machine pulls this repo to rebuild, including ones without the
  # development bundle (matcha)
  programs.git.enable = true;
}
