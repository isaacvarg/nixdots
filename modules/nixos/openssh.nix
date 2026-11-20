{ ... }:

{
  # key-only SSH, so a machine can be run from another one
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # public halves of the 1Password SSH keys allowed in
  users.users.isaac.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGdP7GcK83E6NtPh69d59KKH0+9Dj5DjbNUEgzbXapY nixos#latte"
  ];
}
