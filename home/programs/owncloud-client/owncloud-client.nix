{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.owncloud-client;

  # Import your custom package from package.nix
  owncloudClientPackage = import ./package.nix {inherit pkgs lib;};
in {
  options = {
    services.owncloud-client = {
      enable = mkEnableOption "OwnCloud Client";

      # Set default package to your custom one
      package = mkOption {
        type = types.package;
        default = owncloudClientPackage;
        description = "OwnCloud Client package";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (hm.assertions.assertPlatform "services.owncloud-client" pkgs
        platforms.linux)
    ];

    systemd.user.services.owncloud-client = {
      Unit = {
        Description = "OwnCloud Client";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Environment = ["PATH=${config.home.profileDirectory}/bin"];
        ExecStart = "${cfg.package}/bin/owncloud";
      };

      Install = {WantedBy = ["graphical-session.target"];};
    };
  };
}
