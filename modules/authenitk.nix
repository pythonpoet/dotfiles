{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  authentikDefaults = {
    
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
    services.authentik = {
      enable = true;
      # The environmentFile needs to be on the target host!
      # Best use something like sops-nix or agenix to manage it
      environmentFile = "/run/secrets/authentik/authentik-env";
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
  };
}