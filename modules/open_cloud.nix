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
  #
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
      default = 9200;
    };
    domain = mkOption {
      type = types.str;
      default = "https://cloud.davidwild.ch";
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
    OC_LOG_LEVEL = "debug";
    PROXY_TLS = "false";
    HTTP_TLS = "false";
    OC_JWT_SECRET = "whatever";
    
    STORAGE_USERS_DRIVER = "ocis";

    PROXY_EXTERNAL_ADDR = "https://cloud.davidwild.ch";
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
    PROXY_HTTP_ADDR = "0.0.0.0:9200";

    # --- Web Frontend & CSP ---
    WEB_OIDC_CLIENT_ID = "9jFTfaHSUZuztAPiiGu6dYciLDyeIRkXsixnZsxx";
    WEB_OIDC_AUTHORITY = "https://cloud.davidwild.ch";
    WEB_OIDC_METADATA_URL = "https://cloud.davidwild.ch/.well-known/openid-configuration";
    PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";

    COLLABORA_DOMAIN = "https://office.davidwild.ch";
    FRONTEND_APP_HANDLER_VIEW_APP_ADDR = "eu.opencloud.api.collaboration";
    COLLABORATION_APP_NAME = "OnlyOffice";
		COLLABORATION_APP_PRODUCT = "OnlyOffice";
		COLLABORATION_WOPI_SRC =  "http://0.0.0.0:9982"; #<- Internal Link to the OpenCloud-Service and add 1/2*
		COLLABORATION_APP_ADDR =  "https://office.davidwild.ch"; #<- External Link to OnlyOffice for iframe
		COLLABORATION_APP_INSECURE ="true";
    COLLABORATION_LOG_LEVEL = "info";

		
		#COLLABORATION_HTTP_ADDR = "0.0.0.0:9300"; #<- listen to all interfaces or
    #COLLABORATION_GRPC_ADDR = "0.0.0.0:9301";
    # OC_REVA_GATEWAY = "127.0.0.1:9142";
    # COLLABORATION_CS3_GATEWAY = "127.0.0.1:9142";
    COLLABORATION_OO_SECRET = "whatever";
    
    PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none"; 
    PROXY_OIDC_SKIP_USER_INFO = "false"; # Changed to true to fix 401 errors
    MICRO_REGISTRY = "nats-js-kv";
    MICRO_REGISTRY_ADDRESS = "0.0.0.0:9233";

    GODEBUG = "netdns=go";
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
    environment.etc."opencloud/csp.yaml".text = ''
      directives:
        connect-src:
          - "'self'"
          - "blob:"
          - "https://update.opencloud.eu/"
          - "https://office.davidwild.ch"
          - "http://office.davidwild.ch"
          - "https://auth.davidwild.ch"
          - "https://cloud.davidwild.ch"
          - "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
        script-src:
          - "'self'"
          - "'unsafe-inline'"
        style-src:
          - "'self'"
          - "'unsafe-inline'"
        # Inherit defaults for others
        child-src: ["'self'"]
        font-src: ["'self'"]
        frame-src: ["'self'", "blob:", "https://embed.diagrams.net/", "https://office.davidwild.ch"]
        img-src: ["'self'", "data:", "blob:"]
        media-src: ["'self'"]
        object-src: ["'self'", "blob:"]
        manifest-src: ["'self'"]
        frame-ancestors: ["'self'", "https://cloud.davidwild.ch"] 
    '';
   services.onlyoffice = mkIf cfg.enable_onlyoffice {
    enable = true;
    port = 9982;
    enableExampleServer = true;
    examplePort = 9982;
    #enableExampleServer = true;
    hostname = "office.davidwild.ch";
    postgresPasswordFile = config.age.secrets.onlyoffice.path;
    securityNonceFile = config.age.secrets.onlyofficesec.path;
    # TODO implement
    jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;

  };
  # ... other config ...

  systemd.services.onlyoffice-docservice.serviceConfig.ExecStartPre = lib.mkForce (
    let
      # Use the same 'cfg' logic from the OnlyOffice module
      ooCfg = config.services.onlyoffice;
      
      onlyoffice-prestart-fixed = pkgs.writeShellScript "onlyoffice-prestart-fixed" ''
        PATH=$PATH:${lib.makeBinPath [ pkgs.jq pkgs.moreutils config.services.postgresql.package ]}
        umask 077
        mkdir -p /run/onlyoffice/config/ /var/lib/onlyoffice/documentserver/sdkjs/{slide/themes,common}/ /var/lib/onlyoffice/documentserver/{fonts,server/FileConverter/bin}/
        cp -r ${ooCfg.package}/etc/onlyoffice/documentserver/* /run/onlyoffice/config/
        chmod u+w /run/onlyoffice/config/default.json

        FS_SECRET_STRING=$(cut -d '"' -f 2 < ${ooCfg.securityNonceFile})
        
        # We inject .wopi.enable = true here to fix the 404 on /hosting/discovery
        jq '
          .storage.fs.secretString = "'$FS_SECRET_STRING'" |
          .services.CoAuthoring.server.port = ${toString ooCfg.port} |
          .services.CoAuthoring.sql.dbHost = "${ooCfg.postgresHost}" |
          .services.CoAuthoring.sql.dbName = "${ooCfg.postgresName}" |
          .services.CoAuthoring.sql.dbUser = "${ooCfg.postgresUser}" |
          .wopi.enable = true |
          .rabbitmq.url = "${ooCfg.rabbitmqUrl}"
          ${lib.optionalString (ooCfg.postgresPasswordFile != null) ''
            | .services.CoAuthoring.sql.dbPass = "'"$(cat ${ooCfg.postgresPasswordFile})"'"
          ''}
          ${lib.optionalString (ooCfg.jwtSecretFile != null) ''
            | .services.CoAuthoring.token.enable.browser = true
            | .services.CoAuthoring.token.enable.request.inbox = true
            | .services.CoAuthoring.token.enable.request.outbox = true
            | .services.CoAuthoring.secret.inbox.string = "'"$(cat ${ooCfg.jwtSecretFile})"'"
            | .services.CoAuthoring.secret.outbox.string = "'"$(cat ${ooCfg.jwtSecretFile})"'"
            | .services.CoAuthoring.secret.session.string = "'"$(cat ${ooCfg.jwtSecretFile})"'"
          ''}
        ' /run/onlyoffice/config/default.json | sponge /run/onlyoffice/config/default.json

        chmod u+w /run/onlyoffice/config/production-linux.json
        jq '.FileConverter.converter.x2tPath = "${ooCfg.x2t}/bin/x2t"' \
          /run/onlyoffice/config/production-linux.json | sponge /run/onlyoffice/config/production-linux.json

        # Ensure database is ready
        if psql -d onlyoffice -c "SELECT 'task_result'::regclass;" >/dev/null 2>&1; then
          psql -d onlyoffice -f ${ooCfg.package}/var/www/onlyoffice/documentserver/server/schema/postgresql/removetbl.sql
        fi
        psql -d onlyoffice -f ${ooCfg.package}/var/www/onlyoffice/documentserver/server/schema/postgresql/createdb.sql
      '';
    in
      [ onlyoffice-prestart-fixed ]
  );
  services.nginx = {
    # 1. The Upstream Fix: Forces Nginx to use IPv4 (127.0.0.1) instead of IPv6 ([::1])
    # This solves the "Connection Refused" error we saw in your logs.
    # upstreams."onlyoffice-docservice".servers = lib.mkForce {
    #   "127.0.0.1:9982" = { };
    # };

    # 2. The VirtualHost Fix: Merges SSL and Redirect logic into the OnlyOffice domain
    virtualHosts."office.davidwild.ch" = {
      #addSSL = true;
      enableACME = true;
      forceSSL = true; # Automatically redirects http:// to https://
      locations."/" = {
      # proxyPass = "http://0.0.0.0:9982";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

      extraConfig = ''
        # OnlyOffice needs to be able to be framed by your cloud domain
        # We must clear any global 'DENY' headers
        more_clear_headers "X-Frame-Options";
        
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
      '';
    };
    virtualHosts."cloud.davidwild.ch" = {
  # ... your existing SSL config ...
  extraConfig = ''
    # Disable buffering for SSE (Server-Sent Events)
    proxy_buffering off;
    proxy_cache off;
    proxy_read_timeout 24h;
    
    # Required for OpenCloud internal communication
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  '';
  };
  virtualHosts."wopi.davidwild.ch" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://0.0.0.0:9300";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
  };

    services.tika = {
      enable = true;
      port = 9998;
      # Optional: listen only on localhost for security
      listenAddress = "127.0.0.1";
    };
    #TODO add collabora
    # virtualisation.oci-containers = {
    #   backend = "podman";
    #   containers = {

    #     collabora = mkIf cfg. {
    #       image = "collabora/code";
    #       ports = ["9980:9980"];
    #       autoStart = true;
    #       environment = {
    #         extra_params = "--o:ssl.enable=false";
    #       };
    #     };
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
          hosts = ["0.0.0.0:${toString cfg.port_radicale}" "[::]:${toString cfg.port_radicale}"];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "${cfg.path_radicale}/users";
          htpasswd_encryption = "autodetect";
        };
        storage = {
          filesystem_folder = "${cfg.path_radicale}/collections";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [9200 9980 8222 4222 9998 5232];
  };
}

