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

    enable_collabora = mkOption {
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
    OC_EXCLUDE_RUN_SERVICES = "idp";
    OC_LOG_LEVEL = "error";

    # --- Proxy & User Mapping ---
    PROXY_OIDC_REWRITE_WELLKNOWN = "true";
    PROXY_AUTOPROVISION_ACCOUNTS = "true";
    GRAPH_USERNAME_MATCH = "none";
    PROXY_USER_OIDC_CLAIM = "preferred_username";
    PROXY_USER_CS3_CLAIM = "username";

    # --- Web Frontend & CSP ---
    WEB_CSP_REPORT_ONLY = "false";
    WEB_OIDC_CLIENT_ID = "9jFTfaHSUZuztAPiiGu6dYciLDyeIRkXsixnZsxx";
    WEB_OIDC_AUTHORITY = "https://cloud.davidwild.ch";
    WEB_OIDC_METADATA_URL = "https://cloud.davidwild.ch/.well-known/openid-configuration";
    # This fixes your final CSP 'token' error:
    #WEB_CSP_CONNECT_SRC = "'self' blob: https://auth.davidwild.ch https://raw.githubusercontent.com/opencloud-eu/awesome-apps/";
  };

  # Only use settings for complex nested structures like role mapping
  settings = {
    proxy.role_assignment = {
      driver = "oidc";
      oidc_role_mapper.role_claim = "opencloud_roles";
    };
    web.web.config.csp.directives.connect-src = [
      "'self'"
      "blob:"
      "https://auth.davidwild.ch"
      "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
      "https://auth.davidwild.ch/application/o/token/"
    ];
  };
};
    
    #TODO add collabora
    # virtualisation.oci-containers = {
    #   backend = "podman";
    #   containers = {

    #     collabora = mkIf cfg.enable_collabora {
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
    networking.firewall.allowedTCPPorts = [9200 9980 9998 5232];
  };
}

