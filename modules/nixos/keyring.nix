{ pkgs, ... }:

{
services.gnome.gnome-keyring.enable = true;

security.pam.services.login.enableGnomeKeyring = true;

# gui to inspect
programs.seahorse.enable = true;
environment.systemPackages = [ pkgs.libsecret ];

}
