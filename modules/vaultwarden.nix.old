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
  networking.firewall.allowedTCPPorts = [9988];

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      vaultwarden = {
        image = "vaultwarden/server";
        ports = ["9988:80"];

        volumes = [
          "/var/lib/vaultwarden/:/data/"
        ];

        environment = {
          DOMAIN = "vault.chaosdam.net";
          SIGNUPS_ALLOWED = "false";
          ADMIN_TOKEN = "7JYcU*NZ6mRoo46hnw8cKRk$L#ynQ6^h2%79Edws";
        };
      };
    };
  };
}
