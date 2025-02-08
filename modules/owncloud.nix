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
  cfg = config.ocis;
in {
  options.ocis = {
    enable = mkEnableOption "Enable ownCloud infininty Scale (ocis)";
    data_dir = mkOption {
      type = types.str;
    };
    config_file = mkOption {
      type = types.str;
    };
    image = mkOption {
      type = types.str;
      default = "owncloud/ocis:7.0";
    };
    port = mkOption {
      type = types.port;
      default = 9200;
    };
    domain = mkOption {
      type = types.str;
      default = "https://cloud.chaosdam.net";
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
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        ocis = {
          image = cfg.image;
          ports = ["${toString cfg.port}:9200"];
          volumes = [
            "${cfg.config_file}:/etc/ocis/ocis.yaml"
            "${cfg.data_dir}:/var/lib/ocis"
          ];
          environment = {
            OCIS_URL = cfg.domain;
            OCIS_LOG_LEVEL = "error";
            OCIS_INSECURE = "true";
            TLS_INSECURE = "true";
            TLS_SKIP_VERIFY_CLIENT_CERT = "true";
            WEBDAV_ALLOW_INSECURE = "true";

            # Collabora
            COLLABORATION_APP_NAME = mkIf cfg.enable_collabora "Collabora";
            COLLABORATION_APP_PRODUCT = mkIf cfg.enable_collabora "Collabora";
            COLLABORATION_APP_DESCRIPTION = mkIf cfg.enable_collabora "Open office documents with Collabora";
            COLLABORATION_APP_ICON = mkIf cfg.enable_collabora "image-edit";
            COLLABORATION_APP_ADDR = mkIf cfg.enable_collabora "http://127.0.0.1:9980";
            COLLABORATION_APP_INSECURE = mkIf cfg.enable_collabora "true";
            COLLABORATION_APP_PROOF_DISABLE = mkIf cfg.enable_collabora "true";

            # Tika
            SEARCH_EXTRACTOR_TYPE = mkIf cfg.enable_full_text_search "tika";
            SEARCH_EXTRACTOR_TIKA_TIKA_URL = mkIf cfg.enable_full_text_search "http://tika:9998";
            FRONTEND_FULL_TEXT_SEARCH_ENABLED = mkIf cfg.enable_full_text_search "true";
          };
        };

        collabora = mkIf cfg.enable_collabora {
          image = "collabora/code";
          ports = ["9980:9980"];
          autoStart = true;
          environment = {
            extra_params = "--o:ssl.enable=false";
          };
        };
        tika = mkIf cfg.enable_full_text_search {
          image = "apache/tika:latest-full";
          ports = ["9998:9998"];
        };
      };
    };
    networking.firewall.allowedTCPPorts =
      (
        if cfg.enable
        then [9980]
        else []
      )
      ++ [9200];
  };
}
