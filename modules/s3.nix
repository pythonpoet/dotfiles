{ config, pkgs, lib, ... }:

{
    services.garage = {
        enable = true;
        package = pkgs.garage;
        settings = {
            replication_factor = 1;

            rpc_bind_addr = "[::]:3901";
            # Generate with: openssl rand -hex 32
            # and store in a secret file, then reference it here
            rpc_secret_file = "/etc/keys/garage-rpc-secret";

            s3_api = {
                s3_region = "zurich";
                api_bind_addr = "0.0.0.0:9000"; # same port as minio
                root_domain = ".s3.local";
            };

            admin = {
                api_bind_addr = "0.0.0.0:3903";
            };

            data_dir = [{ path = "/data1/garage/data"; capacity = "1T"; }];
            metadata_dir = "/data1/garage/meta";
        };
    };

    # Open firewall if needed
    networking.firewall.allowedTCPPorts = [ 9000 3901 ]; # 9000 = S3 API, 3901 = RPC

    systemd.services.garage.serviceConfig.DynamicUser = lib.mkForce false;

    systemd.services.garage.serviceConfig.User = "garage";
    systemd.services.garage.serviceConfig.Group = "garage";

    users.users.garage = {
        isSystemUser = true;
        group = "garage";
        extraGroups = [ "keys" ];
    };
    users.groups.garage = {};

    systemd.tmpfiles.rules = [
        "d /data1/garage/data 0700 garage garage -"
        "d /data1/garage/meta 0700 garage garage -"
    ];
    services.caddy = {
        enable = true;
        virtualHosts."kaepfnach:9001" = {
            extraConfig = ''
            tls internal
            reverse_proxy localhost:9000
            '';
        };
    };
}
