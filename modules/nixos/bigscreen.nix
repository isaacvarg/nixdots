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

  # plasma-bigscreen builds against kdeconnect-kde and qtwebengine but doesn't
  # install them, so the home screen can't load their QML modules and stays
  # blank. The kdeconnect module also opens its firewall ports, which lets a
  # phone work as the remote.
  programs.kdeconnect.enable = true;

  environment.systemPackages = [
    pkgs.kdePackages.plasma-bigscreen
    pkgs.kdePackages.qtwebengine
  ];

  environment.etc."xdg/kscreenlockerrc".text = ''
    [Daemon]
    Autolock=false
    LockOnResume=false
  '';

  services.udev.packages = [ pkgs.libcec ];
  users.users.isaac.extraGroups = [ "dialout" ];
}
