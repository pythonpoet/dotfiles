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
      #configDir = cfg.config_file;
      stateDir = cfg.data_dir;
      settings = {
        oidc.issuer = "https://auth.davidwild.ch/application/o/opencloud/";
          proxy = {
            auto_provision_accounts = true;
            oidc = {
              rewrite_well_known = true;
              issuer = "https://auth.davidwild.ch/application/o/opencloud/";
            };
            role_assignment = {
              driver = "oidc";
              oidc_role_mapper = {
                role_claim = "opencloud_roles";
              };
            };
          };
          web = {
            web = {
              config = {
                oidc = {
                  authority = "https://auth.davidwild.ch/application/o/opencloud/";
                  scope = "openid profile email opencloud_roles";
                };
              };
            };
          };
        };
      environment = {
        OC_OIDC_ISSUER = "https://auth.davidwild.ch/application/o/opencloud/";
        OC_EXCLUDE_RUN_SERVICES = "idp";
        
        PROXY_OIDC_REWRITE_WELLKNOWN = "true";
        PROXY_AUTOPROVISION_ACCOUNTS = "true";
        GRAPH_USERNAME_MATCH = "true";
        PROXY_USER_OIDC_CLAIM = "preferred_username";
        PROXY_USER_CS3_CLAIM = "username";
        WEB_OIDC_AUTHORITY = "https://cloud.davidwild.ch";

      };
      # environment = {
      #     OC_URL = cfg.domain;
      #     OC_LOG_LEVEL = "error";
      #     OC_INSECURE = "true";
      #     TLS_INSECURE = "true";
      #     # if certifciate expiration problem: delete ldap.crt and ldap.key in OC-data/idm
      #     IDP_LDAP_TLSSKIPVERIFY = "true";
      #     MICRO_REGISTRY = "nats-js-kv";
      #     # auth

      #     OC_OIDC_ISSUER="https://auth.davidwild.ch/application/o/opencloud/";
      #     OC_OIDC_CLIENT_ID="nNlMbe2mhzvQMHyC7YWi6ZMO8HpPHu2EwfOzumgT";
          
      #     #PROXY_OIDC_REWRITE_WELLKNOWN="true";
      #     #PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD="none";
      #     # WEB_OIDC_CLIENT_ID="ocis";
      #     # PROXY_OIDC_ISSUER="https://auth.davidwild.ch/application/o/opencloud/";
      #     # PROXY_OIDC_REWRITE_WELLKNOWN="true";
      #     # PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD="none";
      #     # PROXY_OIDC_SKIP_USER_INFO="false";
      #     # PROXY_AUTOPROVISION_ACCOUNTS="false";
      #     # PROXY_AUTOPROVISION_CLAIM_USERNAME="preferred_username";
      #     # PROXY_AUTOPROVISION_CLAIM_EMAIL="email";
      #     # PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME="name";
      #     # PROXY_AUTOPROVISION_CLAIM_GROUPS="groups";

      #     # Collabora
      #     COLLABORATION_APP_NAME = mkIf cfg.enable_collabora "Collabora";
      #     COLLABORATION_APP_PRODUCT = mkIf cfg.enable_collabora "Collabora";
      #     COLLABORATION_APP_DESCRIPTION = mkIf cfg.enable_collabora "Open office documents with Collabora";
      #     COLLABORATION_APP_ICON = mkIf cfg.enable_collabora "image-edit";
      #     COLLABORATION_APP_ADDR = mkIf cfg.enable_collabora "http://127.0.0.1:9980";
      #     COLLABORATION_APP_INSECURE = mkIf cfg.enable_collabora "true";
      #     COLLABORATION_APP_PROOF_DISABLE = mkIf cfg.enable_collabora "true";

      #     # Tika
      #     SEARCH_EXTRACTOR_TYPE = mkIf cfg.enable_full_text_search "tika";
      #     SEARCH_EXTRACTOR_TIKA_TIKA_URL = mkIf cfg.enable_full_text_search "http://localhost:9998";
      #     FRONTEND_FULL_TEXT_SEARCH_ENABLED = mkIf cfg.enable_full_text_search "true";
      #   };
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

