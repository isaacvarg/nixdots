{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../bundles/nixos/common.nix
      ../../bundles/nixos/media.nix
      ../../bundles/nixos/gaming.nix
      ../../modules/nixos/bluetooth.nix
      ../../modules/nixos/openssh.nix
      ../../modules/nixos/sops.nix
   ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "matcha";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # boot straight into Bigscreen, no login screen
  services.displayManager.autoLogin = {
      enable = true;
      user = "isaac";
  };

  programs.fish.enable = true;

  # The password is only for sudo and the console; autologin skips it.
  # neededForUsers decrypts it before NixOS creates the user.
  sops.secrets."isaac/hashed-password" = {
    sopsFile = ../../secrets/matcha.yaml;
    neededForUsers = true;
  };

  users.users."isaac" = {
    isNormalUser = true;
    description = "isaac";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."isaac/hashed-password".path;
    packages = with pkgs; [];
  };

  system.stateVersion = "26.05";

}
