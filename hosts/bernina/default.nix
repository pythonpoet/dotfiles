{ config, lib, pkgs, inputs, ... }:
let
  kernelBundle = pkgs.linuxAndFirmware.v6_12_47; # or latest supported
  nix-settings = ({ config, ... }:{
    nix.registry.nixpkgs.to.path = lib.mkForce inputs.nixpkgs.outPath;
  });
  # Ubuntu patch that lets the kernel lie about the machine type
  compatUtsPatch = pkgs.fetchpatch {
    name   = "compat-uts-machine.patch";
    url    = "https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/jammy/patch/?id=c1da50fa6eddad313360249cadcd4905ac9f82ea";
    hash   = "sha256-357+EzMLLt7IINdH0ENE+VcDXwXJMo4qiF/Dorp2Eyw=";
  };
  users-config-stub = ({ config, ... }: {
        # This is identical to what nixos installer does in
        # (modulesPash + "profiles/installation-device.nix")

        # Use less privileged nixos user
        users.users.david = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
          ];
        };

        # Don't require sudo/root to `reboot` or `poweroff`.
        security.polkit.enable = true;

        # Allow passwordless sudo from nixos user
        security.sudo = {
          enable = true;
          wheelNeedsPassword = false;
        };

        # Automatically log in at the virtual consoles.
        services.getty.autologinUser = "david";

        # We run sshd by default. Login is only possible after adding a
        # password via "passwd" or by adding a ssh key to ~/.ssh/authorized_keys.
        # The latter one is particular useful if keys are manually added to
        # installation device for head-less systems i.e. arm boards by manually
        # mounting the storage in a different system.
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        # allow nix-copy to live system
        nix.settings= {
          trusted-users = [ "david" ];
          experimental-features = ["nix-command" "flakes"];
        };

        # We are stateless, so just default to latest.
        system.stateVersion = config.system.nixos.release;
      });

      network-config = {
        # This is mostly portions of safe network configuration defaults that
        # nixos-images and srvos provide

        services.tailscale.enable = true;

        networking.useNetworkd = true;
        # mdns
        networking.firewall.allowedUDPPorts = [ 5353 ];
        systemd.network.networks = {
          "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
          "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
        };

        # This comment was lifted from `srvos`
        # Do not take down the network for too long when upgrading,
        # This also prevents failures of services that are restarted instead of stopped.
        # It will use `systemctl restart` rather than stopping it with `systemctl stop`
        # followed by a delayed `systemctl start`.
        systemd.services = {
          systemd-networkd.stopIfChanged = false;
          # Services that are only restarted might be not able to resolve when resolved is stopped before
          systemd-resolved.stopIfChanged = false;
        };

        # Use iwd instead of wpa_supplicant. It has a user friendly CLI
        networking.wireless.enable = false;
        networking.wireless.iwd = {
          enable = true;
          settings = {
            Network = {
              EnableIPv6 = true;
              RoutePriorityOffset = 300;
            };
            Settings.AutoConnect = true;
          };
        };
      };

      common-user-config = {config, pkgs, ... }: {
        imports = [
          nix-settings
          users-config-stub
          network-config
        ];

        time.timeZone = "Europe/Zurich";
        networking.hostName = "bernina";

       
        environment.systemPackages = with pkgs; [
          tree
          git
          helix
        ];


        users.users.david.openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOr7hdJO0P2TBs5GH+XmOi7XoBT6LiAS7Ym6IEgM2H0 david@alpakapro"
        ];
        users.users.root.openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOr7hdJO0P2TBs5GH+XmOi7XoBT6LiAS7Ym6IEgM2H0 david@alpakapro"
        ];


        system.nixos.tags = let
          cfg = config.boot.loader.raspberryPi;
        in [
          "raspberry-pi-${cfg.variant}"
          cfg.bootloader
          config.boot.kernelPackages.kernel.version
        ];
      };
      
in 

{
  imports = with inputs.nixos-raspberrypi.nixosModules;
    [ # Include the results of the hardware scan.
      # Hardware configuration
      raspberry-pi-5.base
      #raspberry-pi-5.page-size-16k
      raspberry-pi-5.display-vc4
      raspberry-pi-5.bluetooth
      common-user-config
    ];
  boot = {
    #binfmt.emulatedSystems = [ "armv7l-linux" ];
     loader = {
       raspberryPi.firmwarePackage = pkgs.linuxAndFirmware.v6_12_34.raspberrypifw;    
       raspberryPi.bootloader = "kernel";
      
     };
    
    kernelPackages = kernelBundle.linuxPackages_rpi5;   # <-- keep original
    kernelPatches = [
      { name  = "compat-uts-machine";
        patch = compatUtsPatch;          # <-- the derivation returned by fetchpatch
      }
    ];
    kernelParams = [ 
      "compat_uts_machine=armv7l" 
      "rootwait"             # Wait for root device to exist
      "rootdelay=10" 
      "usbcore.autosuspend=-1"         # Add a 10-second buffer for USB devices to initialize
    ];
    
    supportedFilesystems = [ "ext4" "btrfs" ];
    initrd = {
      # Add xhci_pci to both modules lists for the RPi5 USB bus
      kernelModules = [ "usb_storage" "uas" "pcie_brcmstb" "xhci_pci" "ext4" "btrfs" ];
      availableKernelModules = [ "usb_storage" "uas" "pcie_brcmstb" "xhci_pci" ];
      supportedFilesystems = [ "ext4" "btrfs" ];
    };
    };
    nix.settings = {
      extra-platforms = [ "armv7l-linux" ];   # <── NEW
      system-features = [
        "benchmark"
        "big-parallel"
        "nixos-test"
        "kvm"
        "gccarch-armv7-a"
        "gccarch-armv8-a"
      ];
    };

    nixpkgs.overlays = lib.mkAfter [
      (self: super: {
        # This is used in (modulesPath + "/hardware/all-firmware.nix") when at least 
        # enableRedistributableFirmware is enabled
        # I know no easier way to override this package
        inherit (kernelBundle) raspberrypiWirelessFirmware;
        # Some derivations want to use it as an input,
        # e.g. raspberrypi-dtbs, omxplayer, sd-image-* modules
        inherit (kernelBundle) raspberrypifw;
      })
    ];
 
  fileSystems."/data1" = {
    device = "/dev/disk/by-uuid/5a4cb152-78cc-4f24-9941-a11691c9bbca";
    fsType = "btrfs"; 
    options = ["defaults" "noatime" "compress=zstd" "nofail"];
  };

  fileSystems."/data2" = {
    device = "/dev/disk/by-uuid/96d53b77-8166-4217-8101-cfbc14f64f32";
    fsType = "btrfs";
    options = ["defaults" "noatime" "compress=zstd" "nofail"];
    #neededForBoot = true;
  };
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2175-794E";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # fileSystems."/nix" = {
  #    device = "/dev/disk/by-uuid/c3864b8a-2433-4897-84a2-8e30163a39ef";
  #    fsType = "ext4";
  #    neededForBoot = true;
  #    #depends = [ "/" ];
  #   options = [ "noatime" ];
  # };
  # # check that /nix gets mounted before nix-daemon gets started
  # systemd.services.nix-daemon = {
  #   after = [ "nix.mount" ];
  #   requires = [ "nix.mount" ];
  # };
  swapDevices = [ ];
}
