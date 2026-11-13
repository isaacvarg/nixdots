{ ... }:

{
  services.displayManager.dux-greeter = {
    enable = true;
    compositor.name = "hyprland";
  };

  services.displayManager.defaultSession = "hyprland-uwsm";
}
