{
  pkgs,
  config,
  stdenv,
  ...
}:
let
  oroborusPlymouthTheme = import ../../lib/plymouth/oroborus.nix { inherit pkgs stdenv; };
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
      "splash" # ⬅️ Add this
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
      "plymouth.enable=1" # ⬅️ Add this     # 
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
      themePackages = [ oroborusPlymouthTheme ];
    };
  };
  console = {
    earlySetup = true;
    keyMap = "sg";
  };

  environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
}
