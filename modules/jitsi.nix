{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.jitsi;
in {
  options.jitsi = {
    enable = mkEnableOption "Enable Jitsi";

    domain = mkOption {
      type = types.str;
      default = "jitsi.davidwild.ch";
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [
      "jitsi-meet"
    ];
    services.jitsi-meet = {
      enable = true;
      hostName = cfg.domain;
      prosody.lockdown = true;
      config = {
        enableWelcomePage = false;
        prejoinPageEnabled = true;
        defaultLang = "en";
      };
      interfaceConfig = {
        SHOW_JITSI_WATERMARK = false;
        SHOW_WATERMARK_FOR_GUESTS = false;
      };
      nginx.enable = true;
    };
    services.jitsi-videobridge = {
      openFirewall = true;
      nat = {
        localAddress  = "192.168.0.29";          # your LAN interface
        publicAddress = "jitsi.davidwild.ch";    # or the numeric public IP
      };
    };

      
      # networking.firewall.allowedTCPPorts = [ 80 443 5349 ];   # TURN-TLS
      # networking.firewall.allowedUDPPorts = [ 10000 3478 ];    # media + TURN-UDP
      systemd.services.jitsi-videobridge2 = {
    after = [ "network.target" ]

  };
  
    };
}
