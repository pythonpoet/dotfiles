{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  authentikDefaults = {
    data_dir = "/data1/authentik";
  };
  cfg = config.authentik // authentikDefaults;
in {
  options.authentik = {
    enable = mkEnableOption "Enable authentik";
    paths = mkOption {
      type = types.listOf types.str;
      default = cfg.paths;
    };
    repo_host = mkOption {
      type = types.str;
      default = cfg.repo_host;
    };
    data_dir = mkOption {
      type = types.str;
      default = cfg.data_dir;
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
    services.authentik = {
      enable = true;
      # The environmentFile needs to be on the target host!
      # Best use something like sops-nix or agenix to manage it
      environmentFile = config.age.secrets.authentik.path;
      settings = {
        email = {
          host = "smtp.autistici.org";
          port = 587;
          username = "davidoff@bastardi.net";
          use_tls = true;
          use_ssl = false;
          from = "davidoff@bastardi.net";
        };
        disable_startup_analytics = true;
        avatars = "initials";
      };
      
      nginx = {
        enable = true;
        enableACME = true;
        host = "auth.davidwild.ch";
      };
    };
    systemd.tmpfiles.rules = [
    "d ${cfg.data_dir} 0750 authentik authentik -"
  ];
    systemd.services.authentik = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          ReadWritePaths = [ cfg.data_dir  ];
          BindPaths = [
            "${cfg.data_dir }:/var/lib/authentik"
          ];
        };
      };
  };
}