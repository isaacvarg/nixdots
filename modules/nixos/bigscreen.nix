{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
    defaultSession = "plasma-bigscreen-wayland";
  };

  environment.systemPackages = [ pkgs.kdePackages.plasma-bigscreen ];

  environment.etc."xdg/kscreenlockerrc".text = ''
    [Daemon]
    Autolock=false
    LockOnResume=false
  '';

  services.udev.packages = [ pkgs.libcec ];
  users.users.isaac.extraGroups = [ "dialout" ];
}
