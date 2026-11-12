{ ... }:

{
  imports = [
    ../../modules/nixos/docker.nix
    ../../modules/nixos/nix-ld.nix
    ../../modules/nixos/1password.nix
    ../../modules/nixos/llm-cache.nix
  ];

  networking.firewall.allowedTCPPorts = [
    3000
  ];
}
