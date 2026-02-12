#Guid https://xeiaso.net/blog/borg-backup-2021-01-09/
# https://nixos.wiki/wiki/Borg_backup
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  borgDefaults = {
    paths = [
      "/var/lib/ocis"
      "/var/lib/vikunja"
      "/var/lib/vaultwarden"
    ];
    repo_host = "root@kaepfnach";
    repo_dir = "/data1/";
    startAt = "daily";
  };
  cfg = config.borg // borgDefaults;
in {
  options.borg = {
    enable = mkEnableOption "Enable borg backup";
    paths = mkOption {
      type = types.listOf types.str;
      default = cfg.paths;
    };
    repo_host = mkOption {
      type = types.str;
      default = cfg.repo_host;
    };
    repo_dir = mkOption {
      type = types.str;
      default = cfg.repo_dir;
    };
    passfile = mkOption {
      type = types.str;
      default = cfg.passfile;
    };
    startAt = mkOption {
      type = types.str;
      default = cfg.startAt;
    };
  };
  config = mkIf cfg.enable {
    services.borgbackup.jobs."Immich" = {
      paths = cfg.paths;
      repo = "${cfg.repo_host}:${cfg.repo_dir}";
      startAt = "04:00";
      compression = "zstd";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets.borg.path}";
      };
      prune.keep = {
        last = 2;
      };
      environment.BORG_RSH = "ssh -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new";
    };
  };
}