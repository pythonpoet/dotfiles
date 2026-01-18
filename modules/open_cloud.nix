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
    OC_URL = cfg.domain;
    OC_EXCLUDE_RUN_SERVICES = "idp";
    OC_LOG_LEVEL = "error";
    PROXY_TLS = "false";
    HTTP_TLS = "false";
    # Point to the managed CSP file
    PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";
  };
  # Only use settings for complex nested structures like role mapping
  settings = {
    web.web.config = {
      oidc = {
        authority = "https://cloud.davidwild.ch";
      metadataUrl = "http://127.0.0.1:9200/.well-known/openid-configuration";
      client_id = "9jFTfaHSUZuztAPiiGu6dYciLDyeIRkXsixnZsxx";
      };
    };
    proxy = {
      external_addr = "https://cloud.davidwild.ch";
      auto_provision_accounts = true;
      oidc = {
        issuer = "https://auth.davidwild.ch/application/o/opencloud/";
        access_token_verify_method = "none";
        rewrite_well_known = true;
        skip_user_info = false;
      };
      # Identity Mapping
      user_oidc_claim = "preferred_username";
      user_cs3_claim = "username";
      role_assignment = {
        driver = "default"; 
      };
      # Claim Mapping for Auto-Provisioning
      autoprovision_claims = {
        username = "preferred_username";
        email = "email";
        displayname = "name";
      };
    };
    };
    };
    environment.etc."opencloud/csp.yaml".text = ''
      directives:
        connect-src:
          - "'self'"
          - "blob:"
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
        frame-src: ["'self'", "blob:", "https://embed.diagrams.net/"]
        img-src: ["'self'", "data:", "blob:"]
        media-src: ["'self'"]
        object-src: ["'self'", "blob:"]
        manifest-src: ["'self'"]
        frame-ancestors: ["'self'"]
    '';
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

