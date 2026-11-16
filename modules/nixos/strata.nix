{ pkgs, strata, ... }:

let
  pkg = strata.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = [ pkg ];

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  xdg.portal.extraPortals = [ pkg.fileChooserPortal ];

  services.dbus.packages = [ pkg.fileManagerService ];
}
