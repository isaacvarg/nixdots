{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../bundles/nixos/common.nix
      ../../bundles/nixos/desktop.nix
      ../../bundles/nixos/development.nix
      ../../bundles/nixos/gaming.nix
      ../../modules/nixos/sops.nix
      ../../modules/nixos/nas.nix
      ../../modules/nixos/todoist.nix
      ../../bundles/nixos/entertainment.nix
   ];

  my.nas = {
    host = "192.168.68.65";
    sopsFile = ../../secrets/latte.yaml;
    shares = {
      "/mnt/minimonster/collections" = "collections";
      "/mnt/minimonster/docker" = "docker";
      "/mnt/minimonster/downloads" = "downloads";
      "/mnt/minimonster/glacier" = "glacier";
      "/mnt/minimonster/isaac" = "isaac";
      "/mnt/minimonster/momentos" = "momentos";
      "/mnt/minimonster/personal" = "personal";
      "/mnt/minimonster/pkm" = "pkm";
      "/mnt/minimonster/storage" = "storage";
      "/mnt/minimonster/paperless-inbox" = "paperless-inbox";
    };
  };


  my.todoist.sopsFile = ../../secrets/latte.yaml;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "latte";
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

  programs.fish.enable = true;

  users.users."isaac" = {
    isNormalUser = true;
    description = "isaac";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

    system.stateVersion = "26.05"; # Did you read the comment?

}
