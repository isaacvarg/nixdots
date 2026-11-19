{ pkgs, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
