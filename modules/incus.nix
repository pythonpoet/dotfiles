{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.incus;
  types = lib.types;
in {
  options.incus = {
    enable = lib.mkEnableOption "Enable Incus environment";

    enable_networking = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Whether an Incus environment is allowed to have networking capabilities";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.david.extraGroups = ["incus-admin"];

    networking = lib.mkIf cfg.enable_networking {
      nftables.enable = true;
      firewall = {
        trustedInterfaces = ["incusbr0"];
        interfaces.incusbr0 = {
          allowedTCPPorts = [53 67];
          allowedUDPPorts = [53 67];
        };
      };
    };

    virtualisation = {
      enable = true;
      preseed = {
        config = {
          "core.https_address" = ":8443";
          "images.auto_update_interval" = 9;
        };
        networks = lib.mkIf cfg.enable_networking [
          {
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
            name = "default";
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
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "dir";
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
          }
        ];
      };
    };
  };
}
