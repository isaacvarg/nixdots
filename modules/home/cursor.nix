{ pkgs, lib, ... }:

{
  home.pointerCursor = {
    enable = true;
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  home.packages = [ pkgs.rose-pine-hyprcursor ];

  home.sessionVariables.HYPRCURSOR_THEME = lib.mkForce "rose-pine-hyprcursor";
}
