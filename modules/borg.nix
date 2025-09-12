#Guid https://xeiaso.net/blog/borg-backup-2021-01-09/
# https://nixos.wiki/wiki/Borg_backup
# {config, ...}:
# {
#   services.borgbackup.jobs.alpakapi4 = {
#     paths = [
#       "/mnt/sda1/ocis"
#       "/mnt/sda1/bitwarden"
#     ];
#     encryption.mode = "none";
#     environment.BORG_RSH = "ssh -i /home/david/.ssh/automated/id_ed25519";
#     repo = "ssh://david@192.168.0.21:22/data/ocis_backup";
#     compression = "auto,zstd";
#     startAt = "daily";
#   };
# }
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
    repo_host = "david@100.121.205.61";
    repo_dir = "/backup/hal_backup";
    passfile = "cat /root/borgbackup/passcode";
    startAt = "daily";
  };
  cfg = config.borg // borgDefaults;
in {
  options.borg = {
    enable = mkEnableOption "Enable borg backup";
    paths = mkOption {
      type = types.listOf types.str;
      default = borgDefaults.paths;
    };
    repo_host = mkOption {
      type = types.str;
      default = borgDefaults.repo_host;
    };
    repo_dir = mkOption {
      type = types.str;
      default = borgDefaults.repo_dir;
    };
    passfile = mkOption {
      type = types.str;
      default = borgDefaults.passfile;
    };
    startAt = mkOption {
      type = types.str;
      default = borgDefaults.startAt;
    };
  };
  config = mkIf cfg.enable {
    services.borgbackup.jobs."borgbase" = {
      paths = cfg.paths;
      repo = "ssh://${cfg.repo_host}//${cfg.repo_dir}";
      encryption = {
        mode = "repokey-blake2";
        passCommand = cfg.passfile;
      };
      environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
      compression = "auto,zstd";
      startAt = cfg.startAt;
    };
  };
}
