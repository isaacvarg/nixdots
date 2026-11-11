{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.users.isaac.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];
}
