{ ... }:

{
  # declarative flatpaks via nix-flatpak
  # add apps from any module with: services.flatpak.packages = [ "app.id" ];
  services.flatpak = {
    enable = true;

    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    # remove anything not declared in config
    # might sound annoying but we committing to
    # the declarative nix aproach
    uninstallUnmanaged = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    packages = [ ];
  };
}
