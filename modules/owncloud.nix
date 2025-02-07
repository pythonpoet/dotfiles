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
in {
  networking.firewall.allowedTCPPorts = [9980 9200];

  virtualisation.oci-container = {
    backend = "podman";
    containers = {
      ocis = {
        image = "owncloud/ocis:7.0@sha256:01812e1147aeb2e5b527f19f645326c0e4c8d701800b4546001d64d0ae1307dc";
        ports = ["9200:9200"];

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

      collabora = {
        image = "docker.io/collabora";
        ports = ["9980:9980"];
        autoStart = true;
        environment = {
          # This limits it to this NC instance AFAICT
          #aliasgroup1 = "https://127.0.01:443";
          # Must disable SSL as it's behind a reverse proxy
          extra_params = "--o:ssl.enable=false";
        };
      };
    };
  };

  #virtualisation.oci-containers.containers.wopi-server = {
  #  image = "docker.io/owncloud/ocis-rolling:latest";
  #  ports = [ "9300:9300" ];
  #  autoStart = true;
  #  environment = {
  # This limits it to this NC instance AFAICT
  #    aliasgroup1 = "https://${ncDomain}:443";
  # Must disable SSL as it's behind a reverse proxy
  #   extra_params = "--o:ssl.enable=false";
  # };
  #cmd = [ "ocis collaboration server" ];
  #};

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
