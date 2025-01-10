# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
    #  ../../modules/system.nix
    #  ../../modules/wireguard.nix
    #  ../../modules/tailscale.nix
      #../../modules/ad-guard.nix
    #  ../../modules/reverse-proxy.nix
    #  ../../modules/elixir-server.nix
      #../../modules/dns.nix
      #../../modules/caddy.nix
      #../../modules/dnsmasq.nix
      #../../modules/i3.nix
      # Include networking
      #./host.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.systemPackages = with pkgs; [
    haskellPackages.gpio
    libraspberrypi
  ];
  # service to control the fan
  systemd.services.fan-control = {
    description = "Control the fan depending on the temperature";
    script = ''
      /run/current-system/sw/bin/gpio init 18 out
      temperature=$(/run/current-system/sw/bin/vcgencmd measure_temp | grep -oE '[0-9]+([.][0-9]+)?')
      threshold=65
      if /run/current-system/sw/bin/awk -v temp="$temperature" -v threshold="$threshold" 'BEGIN { exit !(temp > threshold) }'; then
        /run/current-system/sw/bin/gpio write 18 hi
      else
        /run/current-system/sw/bin/gpio write 18 lo
      fi
      /run/current-system/sw/bin/gpio close 18 out
    '';
  };

  systemd.timers.fan-control-timer = {
    description = "Run control fan script regularly";
    timerConfig = {
      OnCalendar = "*-*-* *:0/1:00"; # Run every 10 minutes
      Persistent = true;
      Unit = "fan-control.service";
    };
    wantedBy = [ "timers.target" ];
  };

  #networking.hostName = "bernina-rpi4"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  #networking.defaultGateway = "192.168.0.254";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}


