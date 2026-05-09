# pgBackRest repository host configuration for kaepfnach
# This machine acts purely as the backup storage server.
# It does NOT run PostgreSQL itself.
{
  config,
  lib,
  ...
}:
with lib; let
  pgbackrestDefaults = {
    repoPath      = "/data1/pgbackrest";
    repoUser      = "pgbackrest";
    stanzas       = [ "chuchichaestli"];
    dbHost        = "chuchichaestli";
    dbUser        = "postgres";
    dbPath        = "/var/lib/postgresql";
    retentionFull = 2;
    retentionDiff = 7;
  };
  cfg = config.pgbackrestRepo // pgbackrestDefaults;
in {
  options.pgbackrestRepo = {
    enable = mkEnableOption "Enable pgBackRest repository host";

    repoPath = mkOption {
      type    = types.str;
      default = pgbackrestDefaults.repoPath;
      description = "Path on this host where backups are stored.";
    };
    repoUser = mkOption {
      type    = types.str;
      default = pgbackrestDefaults.repoUser;
      description = "Local user that owns the repository.";
    };
    stanzas = mkOption {
      type    = types.listOf types.str;
      default = pgbackrestDefaults.stanzas;
      description = "List of stanza names (must match DB host config).";
      example = [ "taalbubbl" ];
    };
    dbHost = mkOption {
      type    = types.str;
      default = pgbackrestDefaults.dbHost;
      description = "Hostname or IP of the PostgreSQL DB host.";
    };
    dbUser = mkOption {
      type    = types.str;
      default = pgbackrestDefaults.dbUser;
      description = "SSH user on the DB host (typically postgres).";
    };
    dbPath = mkOption {
      type    = types.str;
      default = pgbackrestDefaults.dbPath;
      description = "PostgreSQL data directory on the DB host.";
    };
    retentionFull = mkOption {
      type    = types.int;
      default = pgbackrestDefaults.retentionFull;
      description = "Number of full backups to retain.";
    };
    retentionDiff = mkOption {
      type    = types.int;
      default = pgbackrestDefaults.retentionDiff;
      description = "Number of differential backups to retain.";
    };
    authorizedKeys = mkOption {
      type    = types.listOf types.str;
      default = [];
      description = "SSH public keys allowed to connect as the repo user (postgres@dbhost).";
      example = [ "ssh-ed25519 AAAA... postgres@yourdbhost" ];
    };
  };

  config = mkIf cfg.enable {

    services.pgbackrest = {
      enable = true;
      user   = cfg.repoUser;
      group  = cfg.repoUser;

      settings =
        {
          global = {
            "repo1-path"           = cfg.repoPath;
            "repo1-retention-full" = toString cfg.retentionFull;
            "repo1-retention-diff" = toString cfg.retentionDiff;
            "log-level-console"    = "info";
            "log-level-file"       = "detail";
            "log-path"             = "/var/log/pgbackrest";
            "process-max"          = "2";
          };
        }
        // listToAttrs (map (stanza: {
          name  = stanza;
          value = {
            pg = [{
              host     = cfg.dbHost;
              hostUser = cfg.dbUser;
              path     = cfg.dbPath;
            }];
          };
        }) cfg.stanzas);
    };

    users.users.${cfg.repoUser}.openssh.authorizedKeys.keys = cfg.authorizedKeys;
  };
}
