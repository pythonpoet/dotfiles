# https://vikunja.io/docs/full-docker-example/
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Default values
  vikunjaDefaults = {
    url = "vikunja.davidwild.ch";
    db_path = "/data1/vikunja/db/vikunja.db";
    files_path = "/data1/vikunja/files";
    port = 3456;
  };
  cfg = config.vikunja;

in {
  options.vikunja = {
    enable = mkEnableOption "Enable Vikunja";
    service_jwtsecret = mkOption {
      type = types.str;
    };
    url = mkOption {
      type = types.str;
      default = "vikunja.davidwild.ch";
    };
    db_path = mkOption {
      type = types.str;
    };
    files_path = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.port;
      default = 3456;
    };

  };

  config = mkIf cfg.enable {
    

    services.vikunja = {
      enable = true;
      port = cfg.port;
      frontendScheme = "https";
      frontendHostname = cfg.url;

     database.path = cfg.db_path;
      
      settings = {
        files.basepath = lib.mkForce cfg.files_path;
        # service = {
        #   JWTSecret = cfg.service_jwtsecret;
        # };
      };

    };
    systemd.services.vikunja = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
      };
    };
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
