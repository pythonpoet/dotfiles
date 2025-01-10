# doc: https://github.com/NixOS/nixpkgs/pull/296679
# doc: https://mynixos.com/nixpkgs/options/services.ocis
# doc: https://github.com/NixOS/nixpkgs/blob/33b9d57c656e65a9c88c5f34e4eb00b83e2b0ca9/nixos/modules/services/web-apps/ocis.md
# TODO Filesystem has to get a bit more sophisticated. see :https://doc.owncloud.com/ocis/next/deployment/storage/general-considerations.html
#     1. NFS, low complexity somewhat scaleable: https://nixos.wiki/wiki/NFS
#     2. Alternatively, ocis supports the s3 protocol, could use cehp or seeweedfs but they are significantly more complex.
{
  config,
  pkgs,
  ...
}: let
  # List of ports to enable
  ports = [
    9200 # ocis
    9142 # gateway
    9150 # sharing
    9242 # app-registry
    45023 # ocdav
    9166 # auth-machine
    9215 # storage-system
    9115 # webdav
    46871 # webfinger
    9216 # storage-system
    9100 # web
    33177 # eventhistory
    9110 # ocs
    9178 # storage-publiclink
    9190 # settings
    9282 # ocm
    9191 # settings
    9280 # ocm
    9164 # app-provider
    9157 # storage-users
    9199 # auth-service
    9186 # thumbnails
    9185 # thumbnails
    9154 # storage-shares
    46833 # sse
    45363 # userlog
    9220 # search
    #9200  # proxy
    9130 # idp
    9140 # frontend
    9160 # groups
    9120 # graph
    9144 # users
    9146 # auth-basic
  ];
in {
  networking.firewall.allowedTCPPorts = ports;
  services.ocis = {
    enable = true;
    address = "0.0.0.0";
    url = "https://ocis.chaosdam.net";
    #environmentFile = config.sops.secrets.ocis-env.path;
    #insecure = true; # (optional, default = false)
    configDir = "/mnt/sda1/ocis/config";
    stateDir = "/mnt/sda1/ocis/data";

    environment = {
      OCIS_INSECURE = "true";
      TLS_INSECURE = "true";
      TLS_SKIP_VERIFY_CLIENT_CERT = "true";
      WEBDAV_ALLOW_INSECURE = "true";

      # Collabora
      COLLABORATION_APP_NAME = "Collabora";
      COLLABORATION_APP_PRODUCT = "Collabora";
      COLLABORATION_APP_DESCRIPTION = "Open office documents with Collabora";
      COLLABORATION_APP_ICON = "image-edit";
      COLLABORATION_APP_ADDR = "http://127.0.0.1:9980";
      COLLABORATION_APP_INSECURE = "true";
      COLLABORATION_APP_PROOF_DISABLE = "true";
    };
  };
}
