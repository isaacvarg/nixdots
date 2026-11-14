{ ... }:

{
  imports = [ ./flatpak.nix ];

  services.flatpak = {
    remotes = [{
      name = "artcraft-oci";
      location = "https://getartcraft.com/artcraft-oci.flatpakrepo";
    }];

    packages = [
      { appId = "ai.storyteller.artcraft-launcher"; origin = "artcraft-oci"; }
    ];
  };
}
