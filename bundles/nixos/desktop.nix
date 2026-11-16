{ ... }:

{
  imports = [
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/localsend.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/keyring.nix
    ../../modules/nixos/greeter.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/bluetooth.nix
  ];
}
