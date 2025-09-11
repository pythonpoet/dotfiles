{
  pkgs,
  config,
  ...
}:
let
  oroborusPlymouthTheme = import ../../lib/plymouth/oroborus.nix { inherit pkgs; };
in
{
  boot = {
    bootspec.enable = true;

    initrd = {
      systemd.enable = true;
      supportedFilesystems = [ "brtfs" ];
    };

    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
      "plymouth.use-simpledrm"
    ];

    loader = {
      # systemd-boot on UEFI
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    #plymouth.enable = true;
    plymouth = {
      enable = true;

      theme = "oroborus";
      themePackages = oroborusPlymouthTheme;
    };
  };
  console = {
    earlySetup = true;
    keyMap = "sg";
    plymouth.enable = true;
  };

  environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
}
