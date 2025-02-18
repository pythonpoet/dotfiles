# Initialisation of incus;
# Its primarily meant as a sandbox environment for educational purposes and to try new things.
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.incus;
in {
  option.incus = {
    enable = mkEnableOption "Enable Incus environmet";

    allow_networking = mkOption {
      type = types.bool;
      default = false;
      description = "Wheather a Incus environment is allowed to have networking capabilites";
    };
  };
  config = mkIf cfg.enable {
    users.users.david.extraGroups = ["incus-admin"];
    networking = mkIf cfg.allow_networking {
      nftables.enable = true;
      firewall = {
        trustedInterfaces = ["incusbr0"];
        incusbr0 = {
          allowedTCPPorts = [53 67];
          allowedUDPPorts = [53 67];
        };
      };
    };
    virtualisation = {
      enable = true;
      preseed = {
        # this is configuration of the incusd server side:
        config = {
          "core.https_address" = ":8443";
          "images.auto_update_interval" = 9;
        };
        networks = mkIf cfg.allow_networking [
          {
            # this is configuration of the incusd server side:
            config = {
              "ipv4.nat" = "true";
              "ipv4.address" = "10.32.241.1/24";
              "ipv4.dhcp" = "true";
              "ipv4.dhcp.ranges" = "10.32.241.50-10.32.241.150";
              "ipv4.firewall" = "false";
              "ipv6.address" = "fd42:c3ac:167a:93e9::1/64";
              "ipv6.nat" = "true";
              "ipv6.firewall" = "false";
            };
            name = "incusbr0";
            type = "bridge";
          }
        ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                size = "35GiB";
                type = "disk";
              };
            };
            name = "default";
          }
        ];
        storage_pools = [
          {
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
            driver = "dir";
            name = "default";
          }
        ];
      };
    };
  };
}
