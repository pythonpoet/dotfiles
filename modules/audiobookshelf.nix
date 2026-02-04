{config, lib,pkgs,  ...}: 
with lib; let 
  audiobookshelfDefaults = {

  };
  cfg = config.audiobookshelf // audiobookshelfDefaults;
  
in
{
  options.audiobookshelf = {
    enable = mkEnableOption "Enable audiobookshelf server";
    data_dir = mkOption {
      type = types.str;
      default = "/data1/audiobookshelf";
    };
    port = mkOption {
      type = types.port;
      default = 9981;
    };
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
  };
  config = mkIf cfg.enable {
    services.nginx.virtualHosts."audiobookshelf.davidwild.ch" = {
          addSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Request-Id $request_id; # Add X-Request-Id header
              client_max_body_size 32G;
              '';
          };
        };
     
  services.audiobookshelf = {
    enable = true;
    port = cfg.port;
    host = cfg.host;
    openFirewall = true;
  };
  # Override the official service configuration
  systemd.services.audiobookshelf = {
    # 1. Ensure the directory exists with correct permissions
    preStart = ''
      mkdir -p ${cfg.data_dir}
      chown -R audiobookshelf:audiobookshelf ${cfg.data_dir}
    '';

    serviceConfig = {
      # 2. Clear the StateDirectory to prevent systemd from looking at /var/lib
      StateDirectory = lib.mkForce ""; 
      
      # 3. Point the WorkingDirectory and Environment to your drive
      WorkingDirectory = lib.mkForce cfg.data_dir;
      
      # Audiobookshelf uses these paths for its internal database and config
      Environment = [
        "CONFIG_PATH=${cfg.data_dir}/config"
        "METADATA_PATH=${cfg.data_dir}/metadata"
      ];
    };
  };

  };

}
