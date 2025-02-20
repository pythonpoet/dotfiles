{
  pkgs,
  self,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    #./powersave.nix
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
  # 2. Add your kernel patches here
  boot.kernelPatches = [
    # Patch 1
    {
      name = "surface ir-transmitter";
      patch = pkgs.fetchpatch {
        url = "https://lore.kernel.org/platform-driver-x86/Z6uMqiB_cKzM9-iu@kekkonen.localdomain/raw";
        sha256 = "0h37qm9nc2w5082sc5baac2p5lmpm3yrhr3b8hz9avlvccg28469"; # Replace with hash from `nix-prefetch-url`
      };
    }
  ];

  # boot = {
  #   kernelModules = ["i2c-dev"];
  #   kernelParams = [
  #     "amd_pstate=active"
  #     "ideapad_laptop.allow_v4_dytc=Y"
  #     ''acpi_osi="Windows 2020"''
  #   ];
  # };

  # nh default flake
  environment.variables.FLAKE = "/home/david/Documents/dotfiles";

  hardware = {
    xpadneo.enable = true;
    sensor.iio.enable = true;
  };

  networking.hostName = "alpakabook";

  # Looks like an intereting option but not necessary atm
  #security.tpm2.enable = true;

  services = {
    # for SSD/NVME
    fstrim.enable = true;

    howdy = {
      enable = true;
      package = inputs.nixpkgs-howdy.legacyPackages.${pkgs.system}.howdy;
      settings = {
        core = {
          no_confirmation = true;
          abort_if_ssh = true;
        };
        video.dark_threshold = 90;
      };
    };

    linux-enable-ir-emitter = {
      enable = true;
      package = inputs.nixpkgs-howdy.legacyPackages.${pkgs.system}.linux-enable-ir-emitter;
    };
  };
}
