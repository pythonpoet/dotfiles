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
    services.jitsi-videobridge.openFirewall = true;
    
  };
}
