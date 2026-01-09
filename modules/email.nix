{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  emailDefaults = {
    "no-reply@davidwild.ch"
    "contact@davidwild.ch"
  };
  domain = "davidwild.ch";
  cfg = config.email // emailDefaults;
in {
  options.email = {
    enable = mkEnableOption "Enable email";
    emails = mkOption {
      type = types.listOf types.str;
      default = cfg.emails;
    };
    domain = mkOption {
      type = types.str;
      default = cfg.domain;
    };
    
  };
  config = mkIf cfg.enable {
    services.maddy = {
      enable = true;
      primaryDomain = cfg.domain;
      ensureAccounts = cfg.emails;
      ensureCredentials = {
        # Do not use this in production. This will make passwords world-readable
        # in the Nix store
        "no-reply@davidwild.ch".passwordFile = "";
        "contact@davidwild.ch".passwordFile = "";
      };
    };
  };
}