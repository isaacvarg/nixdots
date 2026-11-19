{ skwd-wall, pkgs, ... }:

{
  imports = [ skwd-wall.nixosModules.default ];

  services.skwd-deck.enable = true;

  #   steam workshop stuff, set once outside of nix
  #   1. run `steamcmd +login <user> +quit` once to cache the login
  #   2. in skwd-wall: Settings > Sources > Steam Workshop, pick steamcmd,
  #      enter the username and a Steam Web API key, then restart skwd-walld
  #   annoying but not too bad
  environment.systemPackages = [ pkgs.steamcmd ];
}
