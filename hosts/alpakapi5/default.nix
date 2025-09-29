# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports = with inputs.nixos-raspberrypi.nixosModules;
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Hardware configuration
      raspberry-pi-5.base
      raspberry-pi-5.page-size-16k
      raspberry-pi-5.display-vc4
      raspberry-pi-5.bluetooth
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.registry.nixpkgs.to.path = lib.mkForce inputs.nixpkgs.outPath;

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = false;
  # Add the RPi kernel
  #boot.kernelPackages = inputs.nix-raspi5.legacyPackages.aarch64-linux.linuxPackages_rpi5;
  boot = {
    loader.raspberryPi.firmwarePackage = pkgs.linuxAndFirmware.raspberrypifw;
    kernelPackages = pkgs.linuxAndFirmware.linuxPackages_rpi5;
  };
  #boot.kernelPackages = pkgs.linuxAndFirmware.default;

  networking.hostName = "alpakapi5"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  nix.settings.system-features = [
     "benchmark"
     "big-parallel" 
     "nixos-test"
     "kvm"
     "gccarch-armv8-a"
    ];

  fileSystems."/data1" = {
    device = "/dev/disk/by-uuid/5a4cb152-78cc-4f24-9941-a11691c9bbca";
    fsType = "btrfs";  # ← Make sure this says "btrfs" not "brtfs"
    options = ["defaults" "noatime" "compress=zstd" "nofail"];
  };

  fileSystems."/data2" = {
    device = "/dev/disk/by-uuid/96d53b77-8166-4217-8101-cfbc14f64f32";
    fsType = "btrfs";  # ← Make sure this says "btrfs" not "brtfs"
    options = ["defaults" "noatime" "compress=zstd" "nofail"];
  };

  services.tailscale.enable = true;



  users.users.david = {
    isNormalUser = true;
    description = "david";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    helix
  ];

  # Enable the OpenSSH daemon.
  services.openssh={
    enable = true;
    settings = {
              PasswordAuthentication = true;
    };
  };


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 22 ];

}

