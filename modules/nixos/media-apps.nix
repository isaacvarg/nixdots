{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vacuum-tube
    spotify
    jellyfin-desktop
    mpv
  ];

  # spotify connectinglets phones find this machine and cast to it
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };
}
