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
    db_path = "/data1/vikunja/db";
    files_path = "/data1/vikunja/files";
    port = 3456;
  };
  cfg = config.vikunja // vikunjaDefaults;

in {
  options.vikunja = {
    enable = mkEnableOption "Enable Vikunja";
    service_jwtsecret = mkOption {
      type = types.str;
    };
    package = mkPackageOption pkgs "vikunja" { };
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
    secretConfigFile = mkOption {
      type = types.path;
      default = config.age.secrets.vikunja-config.path;
      description = "Path to the decrypted agenix config.yaml file.";
    };
  };

  config = mkIf cfg.enable {
    services.vikunja = {
      enable = true;
      port = cfg.port;
      frontendScheme = "https";
      frontendHostname = cfg.url;
      environmentFiles = [config.age.secrets.vikunja-config.path];
      settings = {
        auth = {
          local.enabled = false;
          openid = {
            enabled = true;
            providers = [
              {
                name = "Login with Authentik";
                authurl = "https://auth.davidwild.ch/application/o/vikunja/"; 
                clientid = "NYytqakPqAeNuCcDmHcRcge10ADMm7o4yrxUGDau";
                clientsecret = "{client_secret}";
                scope = "openid profile email";
              }
            ];
          };
        };
      };
    };
    systemd.services.vikunja = {
      #environmentFiles = [ cfg.secretConfigFile ];
      systemd.services.vikunja = {
  after = [ "agenix.service" ];
  
    serviceConfig = {
      # Combine all your existing settings here
      ReadWritePaths = [ cfg.db_path ];
      BindPaths = [
        "${cfg.db_path}:/var/lib/vikunja/"
      ];
      SupplementaryGroups = [ "keys" ];
      ReadOnlyPaths = [ "/run/agenix" ];

      # 1. The Patch Script
      # Note: No 'serviceConfig' nesting here!
      ExecStartPre = pkgs.writeShellScript "vikunja-patch-config" ''
        # Get the secret from the age file
        SECRET=$(cat ${config.age.secrets.vikunja.path})
        
        # Use sed to read the Nix-generated config and write it to a writable location.
        # Since you changed the placeholder to {client_secret}, we match that exactly.
        ${pkgs.gnused}/bin/sed "s|{client_secret}|$SECRET|g" /etc/vikunja/config.yaml \
          > /var/lib/vikunja/config.patched.yaml
          
        chmod 600 /var/lib/vikunja/config.patched.yaml
      '';

      # 2. Force Vikunja to use the patched file
      ExecStart = lib.mkForce "${config.services.vikunja.package}/bin/vikunja --config /var/lib/vikunja/config.patched.yaml";
    };
  };
    };
    #environment.etc."vikunja/config.yaml".source = lib.mkForce config.age.secrets.vikunja-config.path;

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
