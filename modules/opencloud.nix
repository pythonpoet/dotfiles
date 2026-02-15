# doc: https://github.com/NixOS/nixpkgs/pull/296679
# doc: https://mynixos.com/nixpkgs/options/services.ocis
# doc: https://github.com/NixOS/nixpkgs/blob/33b9d57c656e65a9c88c5f34e4eb00b83e2b0ca9/nixos/modules/services/web-apps/ocis.md
# TODO Filesystem has to get a bit more sophisticated. see :https://doc.owncloud.com/ocis/next/deployment/storage/general-considerations.html
#     1. NFS, low complexity somewhat scaleable: https://nixos.wiki/wiki/NFS
#     2. Alternatively, ocis supports the s3 protocol, could use cehp or seeweedfs but they are significantly more complex.
#
# https://fariszr.com/owncloud-infinite-scale-docker-setup/
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # List of ports to enable
  internal_host = "127.0.0.1";
  opencould_port = 9200;
  wopi_port = 9300;
  onlyoffice_url = "https://office.davidwild.ch";
  opencloud_url = "https://cloud.davidwild.ch";
  cfg = config.cloud;
in {
  options.cloud = {
    enable = mkEnableOption "Enable open cloud";
    data_dir = mkOption {
      type = types.str;
    };
    config_file = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.port;
      default = opencould_port;
    };
    domain = mkOption {
      type = types.str;
      default = opencloud_url;
    };

    enable_radicale = mkOption {
      type = types.bool;
      default = false;
      description = "Radicale is a sync client for contacts, and calander";
    };
    port_radicale = mkOption {
      type = types.port;
      default = 5232;
    };
    path_radicale = mkOption {
      type = types.str;
    };

    enable_onlyoffice = mkOption {
      type = types.bool;
      default = false;
    };
    enable_full_text_search = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
    services.opencloud = {
      enable = true;
      url = cfg.domain;
      port = cfg.port;
      stateDir = cfg.data_dir;

  # We use environment variables for everything possible to keep the config clean.
  environment = {
    # --- Global / OIDC Core ---
    OC_URL = cfg.domain;
    OC_OIDC_ISSUER = "https://auth.davidwild.ch/application/o/opencloud/";
    PROXY_OIDC_ISSUER = "https://auth.davidwild.ch/application/o/opencloud/";
    OC_EXCLUDE_RUN_SERVICES = "idp";
    OC_ADD_RUN_SERVICES = "collaboration";
    OC_LOG_LEVEL = "info";
    PROXY_TLS = "false";
    HTTP_TLS = "false";
    OC_JWT_SECRET = "whatever";
    
    STORAGE_USERS_DRIVER = "ocis";
    STORAGE_METADATA_DRIVER = "ocis";


    PROXY_EXTERNAL_ADDR = opencloud_url;
    PROXY_AUTOPROVISION_ACCOUNTS = "true";         # Create user on first login

    # --- Role Assignment (Environment Version) ---
    # We set this here to ensure it wins over any stray file configs
    PROXY_ROLE_ASSIGNMENT_DRIVER = "default"; 

    # --- User Mapping ---
    PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
    PROXY_AUTOPROVISION_CLAIM_EMAIL = "email";
    PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "name";
    PROXY_USER_OIDC_CLAIM = "preferred_username";
    PROXY_USER_CS3_CLAIM = "username";
    PROXY_HTTP_ADDR = "${internal_host}:${toString opencould_port}";

    # --- Web Frontend & CSP ---
    WEB_OIDC_CLIENT_ID = "9jFTfaHSUZuztAPiiGu6dYciLDyeIRkXsixnZsxx";
    WEB_OIDC_AUTHORITY = opencloud_url;
    WEB_OIDC_METADATA_URL = "${opencloud_url}/.well-known/openid-configuration";
    PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";


    FRONTEND_APP_HANDLER_VIEW_APP_ADDR =  mkIf cfg.enable_onlyoffice "eu.opencloud.api.collaboration";
    COLLABORA_DOMAIN =  mkIf cfg.enable_onlyoffice "office.davidwild.ch";
    COLLABORATION_APP_NAME =  mkIf cfg.enable_onlyoffice "OnlyOffice";
		COLLABORATION_APP_PRODUCT =  mkIf cfg.enable_onlyoffice "OnlyOffice";
 
		COLLABORATION_WOPI_SRC =  mkIf cfg.enable_onlyoffice "https://wopi.davidwild.ch";
		COLLABORATION_APP_ADDR =   mkIf cfg.enable_onlyoffice onlyoffice_url; 
		COLLABORATION_APP_INSECURE =  mkIf cfg.enable_onlyoffice "true";
    COLLABORATION_LOG_LEVEL =  mkIf cfg.enable_onlyoffice "info";
    COLLABORATION_JWT_SECRET =  mkIf cfg.enable_onlyoffice "whatever";
    COLLABORATION_CS3API_DATAGATEWAY_INSECURE =  mkIf cfg.enable_onlyoffice "true";
    
    COLLABORATION_OO_SECRET = "whatever";
    
    PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none"; 
    PROXY_OIDC_SKIP_USER_INFO = "false"; # Changed to true to fix 401 errors
    # MICRO_REGISTRY = "nats-js-kv";
    # MICRO_REGISTRY_ADDRESS = "127.0.0.1:9233";
    # GODEBUG="netdns=go";
    # OC_CHECK_REACHABILITY = "false";
    OC_SYSTEM_USER_ID = "akadmin";
  };
  # Only use settings for complex nested structures like role mapping
  settings = {
    web.web.config = {
      oidc = {
        
      };
    };
    proxy = {
      auto_provision_accounts = true;
      oidc = {
        rewrite_well_known = true;
        skip_user_info = false;
      };
      role_assignment = {
        driver = "default"; 
      };
    };

    };
    };
    environment.etc."opencloud/csp.yaml".text = mkIf cfg.enable_onlyoffice ''
      directives:
        connect-src:
          - "'self'"
          - "blob:"
          - "https://office.davidwild.ch"
          - "https://auth.davidwild.ch"
          - "https://cloud.davidwild.ch"
          - "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
          - "https://*.davidwild.ch"
        script-src:
          - "'self'"
          - "'unsafe-inline'"
          - "'unsafe-eval'"
          - "https://cloud.davidwild.ch"
        style-src:
          - "'self'"
          - "'unsafe-inline'"
        child-src: ["'self'"]
        font-src: ["'self'"]
        frame-src:
          - "'self'"
          - "blob:"
          - "https://embed.diagrams.net/"
          - "https://office.davidwild.ch"
          - "https://docs.opencloud.eu"
          - "https://*.davidwild.ch"
          - "http://*.davidwild.ch"
        img-src:
          - "'self'"
          - "data:"
          - "blob:"
          - "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
          - "https://tile.openstreetmap.org/"
          - "https://office.davidwild.ch/"
          - "https://*.davidwild.ch"
        media-src: ["'self'"]
        object-src: ["'self'", "blob:"]
        manifest-src: ["'self'"]
        frame-ancestors: ["'self'", "https://cloud.davidwild.ch"]
    '';
    
   # secrets.onlyoffice = {
  #   file = "/home/david/dotfiles/secrets/onlyoffice.age";
  #   owner = "onlyoffice"; 
  #   group = "onlyoffice"; 
  #   mode = "0440";
  #   };
  #   secrets.onlyoffice-jwt = {
  #   file = "/home/david/dotfiles/secrets/onlyoffice-jwt.age";
  #   owner = "onlyoffice"; 
  #   group = "onlyoffice"; 
  #   mode = "0440";
  #   };
      # secrets.onlyofficesec = {
      # file = "/home/david/dotfiles/secrets/onlyofficesec.age";
      # owner = "onlyoffice"; 
      # group = "onlyoffice"; 
      # mode = "0440";
      # };
  #  services.onlyoffice = mkIf cfg.enable_onlyoffice {
  #   enable = true;
  #   port = 9982;

  #   hostname = "office.davidwild.ch";
  #   postgresPasswordFile = config.age.secrets.onlyoffice.path;
  #   securityNonceFile = config.age.secrets.onlyofficesec.path;
  #   wopi = true;
  #   nginx.enable = false;
  #   # TODO implement
  #   jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;

  # };
  


  services.nginx = {    
    virtualHosts."office.davidwild.ch" = {
      forceSSL = true; # Force browsers to stay on HTTPS
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${internal_host}:9982"; # Use http here!
        proxyWebsockets = true;
      };
    };

    virtualHosts."cloud.davidwild.ch" = {
      forceSSL = true;
      enableACME = true;
  
      # Everything path-related goes inside this block
      locations = {
        "/" = {
          proxyPass = "http://${internal_host}:${toString opencould_port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_cache off;
            proxy_read_timeout 24h;

            proxy_set_header Authorization $http_authorization;
            proxy_pass_header Authorization;

            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };

        "/caldav/" = mkIf cfg.enable_radicale {
          proxyPass = "http://127.0.0.1:5232/";
          extraConfig = ''
            proxy_set_header X-Script-Name /caldav;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Remote-User $remote_user;
            
            # Ensure auth headers are passed through
            proxy_set_header Authorization $http_authorization;
            proxy_pass_header Authorization;
          '';
        };

        "/.well-known/caldav" = mkIf cfg.enable_radicale {
          return = "301 $scheme://$host/caldav/";
        };

        "/carddav/" = mkIf cfg.enable_radicale {
          proxyPass = "http://127.0.0.1:5232/"; # The trailing slash here is important!
          extraConfig = ''
            proxy_set_header X-Script-Name /carddav;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Remote-User $remote_user;
            
            # Ensure auth headers are passed through
            proxy_set_header Authorization $http_authorization;
            proxy_pass_header Authorization;
          '';
        };

        "/.well-known/carddav" = mkIf cfg.enable_radicale {
          return = "301 $scheme://$host/carddav/";
        };
      }; # End of locations
    };
  

  virtualHosts."wopi.davidwild.ch" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString wopi_port}";
    };
  };
  };
  
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {

        onlyoffice =  {
          image = "onlyoffice/documentserver:latest";
          ports = ["9982:80"];
          autoStart = true;
          environment = {

            WOPI_ENABLED= "true";
            JWT_ENABLED = "true";
            JWT_SECRET="whatever";
            NODE_TLS_REJECT_UNAUTHORIZED = "0";
            USE_UNAUTHORIZED_STORAGE = "true";

          };
          extraOptions = [
            "--add-host=bernina:host-gateway"
          ];
        }; };};
    # TODO file search engine opensearch!
    #     tika = mkIf cfg.enable_full_text_search {
    #       image = "apache/tika:latest-full";
    #       ports = ["9998:9998"];
    #     };
    #   };
    # };
    services.radicale = mkIf cfg.enable_radicale {
      enable = true;
      settings = {
        server = {
          hosts = [ "127.0.0.1:5232" ];
          ssl = false;
        };
        auth = {
          type = "http_x_remote_user"; # disable authentication, and use the username that OpenCloud provides is
        };
        web = {
          type = "none";
        };
        storage = {
          filesystem_folder = "${cfg.path_radicale}/collections";
        };
        logging = {
          level = "debug"; # optional, enable debug logging
          bad_put_request_content = true; # only if level=debug
          request_header_on_debug = true; # only if level=debug
          request_content_on_debug = true; # only if level=debug
          response_content_on_debug = true; # only if level=debug
        };
      };
      
    };
    # 1. Create the directory automatically
      systemd.tmpfiles.rules = mkIf cfg.enable_radicale[
        "d ${cfg.path_radicale} 0750 radicale radicale -"
      ];

      # 2. Grant the Radicale service permission to access this path
      systemd.services.radicale.serviceConfig = mkIf cfg.enable_radicale {
        ReadWritePaths = [ cfg.path_radicale ];
        # Ensure the service can create the folder if it's missing
        ConfigurationDirectory = "radicale"; 
      };

    networking.firewall.allowedTCPPorts = [9200 9980 8222 4222 9998 5232];
  };
}

