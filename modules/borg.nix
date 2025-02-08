{
  config,
  pkgs,
  ...
}: let
  borgDefaults = {
    paths = [
      "/var/log/ocis"
    ];
    repo_host = "david@100.121.205.61";
    repo_dir = "/backup/hal_backup";
    passfile = "cat /root/borgbackup/passcode";
    startAt = "daily";
  };
  borgConfig = config.borg // borgDefaults;
in {
  services.borgbackup.jobs."borgbase" = {
    paths = borgConfig.paths;
    repo = "ssh://${borgConfig.repo_host}:${borgConfig.repo_dir}";
    encryption = {
      mode = "repokey-blake2";
      passCommand = borgConfig.passfile;
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
    compression = "auto,zstd";
    startAt = borgConfig.startAt;
  };
}
