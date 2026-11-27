{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vacuum-tube
    spotify
    jellyfin-desktop
    mpv
  ];

  xdg.mime.defaultApplications = lib.genAttrs [
    "video/mp4"
    "video/x-matroska"
    "video/webm"
    "video/quicktime"
    "video/x-msvideo"
    "video/x-flv"
    "video/x-ms-wmv"
    "video/mpeg"
    "video/ogg"
    "video/3gpp"
    "video/3gpp2"
    "video/mp2t"
    "video/x-m4v"
    "video/vnd.avi"
  ] (_: "mpv.desktop");

  # spotify connectinglets phones find this machine and cast to it
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };
}
