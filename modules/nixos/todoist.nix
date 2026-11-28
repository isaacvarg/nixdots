{ config, lib, ... }:

let
  cfg = config.my.todoist;
in
{
  options.my.todoist = {
    sopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        sops file holding `todoist.api-token` for this machine. Decrypted to
        /run/secrets/todoist/api-token, readable only by `user`.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "isaac";
      description = "Local user that can read the token.";
    };
  };

  config = lib.mkIf (cfg.sopsFile != null) {
    sops.secrets."todoist/api-token" = {
      inherit (cfg) sopsFile;
      owner = cfg.user;
      mode = "0400";
    };
  };
}
