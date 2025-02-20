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
      name = "surface ir-transmitter patch 1";
      patch = pkgs.fetchpatch {
        url = "https://lore.kernel.org/platform-driver-x86/20250211072841.7713-2-sakari.ailus@linux.intel.com/raw";
        sha256 = "0if79jq71vs5qqg1yc7ysljsy5a1r2clrynw8rd166gg5dcbwvrv"; # Replace with hash from `nix-prefetch-url`
      };
    }
    {
      name = "surface ir-transmitter patch 2";
      patch = pkgs.fetchpatch {
        url = "https://lore.kernel.org/platform-driver-x86/20250211072841.7713-3-sakari.ailus@linux.intel.com/raw";
        sha256 = "11hadm1123ai7brnqjx05xv9pvghhsx8113q85r2v96awr4l2x7z"; # Replace with hash from `nix-prefetch-url`
      };
    }
    {
      name = "surface ir-transmitter patch 3";
      patch = pkgs.fetchpatch {
        url = "https://lore.kernel.org/platform-driver-x86/20250211072841.7713-4-sakari.ailus@linux.intel.com/raw";
        sha256 = "0fzxray47qmyrj10s6hpdck8565agi744kwrrpd1d7c0bvix62z4"; # Replace with hash from `nix-prefetch-url`
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
