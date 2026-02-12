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

    };

    
    networking.hostName = "alpakapro";

    #security.tpm2.enable = true;
    nix.settings.system-features = [
    "benchmark"
    "big-parallel" 
    "nixos-test"
    "kvm"
    "gccarch-armv8-a"
  ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  environment = {
    variables = { FLAKE = "/home/david/Documents/dotfiles";};

    systemPackages = with pkgs; [
      libcamera 
      gst_all_1.gstreamer 
      gst_all_1.gst-plugins-base 
      gst_all_1.gst-plugins-good 
      gst_all_1.gst-plugins-bad
      opencloud-desktop-shell-integration-resources
      ];
  };

    services = {
      fstrim.enable = true;
      flatpak.enable = true;

      # SSH extras
      fail2ban.enable = true;
        endlessh = {
          enable = true;
          # port = 22;
          # openFirewall = true;
        };
    };

    nix.buildMachines = [
    { hostName = "localhost";
      systems = [ "aarch64-linux" "armv7l-linux" ] ;
      supportedFeatures = [ "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 4;
      protocol = null;
    }];

  };
}
