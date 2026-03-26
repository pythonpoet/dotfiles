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
  ];
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
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;

  };
}
