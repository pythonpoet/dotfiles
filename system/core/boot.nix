{
  pkgs,
  config,
  ...
}: {
  boot = {
    bootspec.enable = true;
    # boot.loader.grub.device = "nodev";

     initrd = {
       systemd.enable = true;
       supportedFilesystems = ["brtfs"];
    #   # I think I didnt enabled lvm
    #   #services.lvm.enable = true;
     };

    # use latest kernel
    #kernelPackages = pkgs.linuxPackages_latest;

    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    loader = {
      # systemd-boot on UEFI
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

     plymouth.enable = true;
  };

  environment.systemPackages = [config.boot.kernelPackages.cpupower];
}
