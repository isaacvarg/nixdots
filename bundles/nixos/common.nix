{ ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  # every machine pulls this repo to rebuild, including ones without the
  # development bundle (matcha)
  programs.git.enable = true;
}
