{ nix-flatpak, ... }:

{
  # artcraft's oci remote needs the desktop session bus to install,
  # so it goes through the per-user nix-flatpak service
  imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    # flathub provides the org.freedesktop.Platform runtime artcraft needs
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "artcraft-oci";
        location = "https://getartcraft.com/artcraft-oci.flatpakrepo";
      }
    ];

    packages = [
      { appId = "ai.storyteller.artcraft-launcher"; origin = "artcraft-oci"; }
    ];

    uninstallUnmanaged = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
