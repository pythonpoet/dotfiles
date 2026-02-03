{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  authentikDefaults = {
    data_dir = "/data1/authentik";
    port = 9443;
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
    port  = mkOption {
      type = types.port;
      default = cfg.port;
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
        listen = "127.0.0.1:${toString cfg.port}"; 
      };
      
      # nginx = {
      #   enable = true;
      #   enableACME = true;
      #   host = "auth.davidwild.ch";
      # };
    };
    networking.firewall.allowedTCPPorts = [cfg.port];
    systemd.tmpfiles.rules = [
    "d ${cfg.data_dir} 0750 authentik authentik -"
  ];
    systemd.services.authentik = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
        
        # 1. This ensures the dynamic user has a persistent ID for this service
        # so environmentFilethat file ownership remains valid across reboots.
        StateDirectory = "authentik"; 
        StateDirectoryMode = "0750";

        # 2. Map your external drive to the internal state dir
        # Note: Systemd will attempt to chown the source of a BindPath 
        # if it's listed as a StateDirectory.
        BindPaths = [
          "${cfg.data_dir}:/var/lib/authentik"
        ];
        #PermissionsStartOnly = false;
      };
    };
    systemd.services.authentik-worker = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
        StateDirectory = "authentik";
        StateDirectoryMode = "0750";
        ReadWritePaths = [ cfg.data_dir ];
        BindPaths = [ "${cfg.data_dir}:/var/lib/authentik" ];
      };
    };
    systemd.services.authentik-migrate = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
        StateDirectory = "authentik";
        StateDirectoryMode = "0750";
        ReadWritePaths = [ cfg.data_dir ];
        BindPaths = [ "${cfg.data_dir}:/var/lib/authentik" ];
      };
    };
    users.users.authentik = {
      isSystemUser = true;
      group = "authentik"; 
    };

    users.groups.authentik = {};
  };
}