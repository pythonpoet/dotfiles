{
  config,
  pkgs,
  self,
  inputs,
  lib,
  ...
}:
{
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

    networking.hostName = "alpakapro";

    #security.tpm2.enable = true;
    nix.settings.system-features = [
    "benchmark"
    "big-parallel" 
    "nixos-test"
    "kvm"
    "gccarch-armv7-a"  # Add this for ARMv7
  ];

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

    #TODO Hydra put somewhere else:
    services.hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      notificationSender = "hydra@localhost";
      # buildMachinesFiles = [];
      useSubstitutes = true;
      listenHost = "127.0.0.1";
    };
    nix.buildMachines = [
    { hostName = "localhost";
      systems = [ "aarch64-linux" "armv7l-linux" ] ;
      supportedFeatures = [ "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 4;
      protocol = null;
    }];

  # https://github.com/NixOS/hydra/issues/1186#issuecomment-1231513076
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";
  };
}
