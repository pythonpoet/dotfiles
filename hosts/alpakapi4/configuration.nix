{
  config,
  pkgs,
  lib,
  ...
}: let
  hostname = "alpakapi4";
  user = "david";
  nixosHardwareVersion = "7f1836531b126cfcf584e7d7d71bf8758bb58969";

  timeZone = "Europe/Zurich";
  defaultLocale = "en_US.UTF-8";
in {
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/${nixosHardwareVersion}.tar.gz"}/raspberry-pi/4"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  networking.hostName = hostname;

  environment.systemPackages = with pkgs; [
    firefox
    vim
    git
    helix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  console.keyMap = "de_CH-latin1";

  time.timeZone = timeZone;

  i18n = {
    defaultLocale = defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      #password = password;
      extraGroups = ["wheel"];
    };
  };

  # Enable passwordless sudo.
  security.sudo.extraRules = [
    {
      users = [user];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Enable GPU acceleration
  # hardware.raspberry-pi."4".fkms-3d.enable = true;

  #  hardware.pulseaudio.enable = false;

  system.stateVersion = "24.11";
}
