{
  config,
  pkgs,
  self,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    #./powersave.nix
  ];

  config = {
    hardware.microsoft-surface = {
      kernelVersion = "stable";
      #surface-control.enable = true;
      #ipts.enable = true;
    };

    #environment.variables.FLAKE = "/home/david/Documents/dotfiles";

    networking.hostName = "alpakabook";

    #security.tpm2.enable = true;

    services = {
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
  };
}
