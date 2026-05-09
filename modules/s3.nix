{ config, pkgs, lib, ... }:

{
    services.minio = {
        enable = true;
        region = "zurich";
        dataDir = [ "/data1/minio/data" ];
        configDir = "/data1/minio/config";
        # Set credentials via environment file (don't hardcode secrets)
        rootCredentialsFile = "/run/keys/mino-credentials";
    };

    # Open firewall if needed
    networking.firewall.allowedTCPPorts = [ 9000 9001 ]; # 9000 = API, 9001 = web console
}
