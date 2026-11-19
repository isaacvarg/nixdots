{ config, lib, pkgs, ... }:

let
  cfg = config.my.nas;
  credentials = config.sops.templates."nas-credentials".path;
in
{
  options.my.nas = {
    host = lib.mkOption {
      type = lib.types.str;
      example = "nas.lan";
      description = "Hostname or IP of the SMB server.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        sops file holding `nas.username` and `nas.password` for this machine.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "isaac";
      description = "Local user that owns the mounted files.";
    };

    shares = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { "/mnt/media" = "media"; };
      description = "Mount point -> share name on the NAS.";
    };
  };

  config = lib.mkIf (cfg.shares != { }) {
    environment.systemPackages = [ pkgs.cifs-utils ];
    boot.supportedFilesystems = [ "cifs" ];

    sops.secrets."nas/username".sopsFile = cfg.sopsFile;
    sops.secrets."nas/password".sopsFile = cfg.sopsFile;

    sops.templates."nas-credentials".content = ''
      username=${config.sops.placeholder."nas/username"}
      password=${config.sops.placeholder."nas/password"}
    '';

    fileSystems = lib.mapAttrs (_: share: {
      device = "//${cfg.host}/${share}";
      fsType = "cifs";
      options = [
        "credentials=${credentials}"
        "uid=${cfg.user}"
        "gid=users"
        "file_mode=0664"
        "dir_mode=0775"
        "noauto"
        "nofail"
        "_netdev"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=15s"
        "x-systemd.requires=network-online.target"
        "x-systemd.after=network-online.target"
      ];
    }) cfg.shares;
  };
}
