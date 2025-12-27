# Edit this configuration file to define what should be insitalled on                                                                                         
# your system.  Help is available in the configuration.nix(5) man page                                                                                        
# and in the NixOS manual (accessible by running ‘nixos-help’).                                                                                               
                                                                                                                                                              
{ config, pkgs, ... }:                                                                                                                                        
                                                                                                                                                              
{                                                                                                                                                             
  imports =                                                                                                                                                   
    [ # Include the results of the hardware scan.   
      ./hardware-configuration.nix                                                                                                           20:47:47 [77/593]
    ];                                                                                                                                                        
                                                                                                                                                              
  # Bootloader.                                                                                                                                               
  boot.loader.systemd-boot.enable = true;                                                                                                                     
  boot.loader.efi.canTouchEfiVariables = true;                                                                                                                
                                                                                                                                                              
  networking.hostName = "badenerstrasse"; # Define your hostname.                                                                                             
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicanti                                                                        
  nix.settings.experimental-features  = [ "nix-command" "flakes" ];                                                                                           
                                                                                                                                                              
                                                                                                                                                              
  # Configure network proxy if necessary                                                                                                                      
  # networking.proxy.default = "http://user:password@proxy:port/";                                                                                            
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";                                                                                         
                                                                                                                                                              
  # Enable networking                                                                                                                                         
  networking.networkmanager.enable = true;                                                                                                                    
                                                                                                                                                              
  # Set your time zone.                                                                                                                                       
  time.timeZone = "Europe/Zurich";                                                                                                                            
                                                                                                                                                              
  # Select internationalisation properties.                                                                                                                   
  i18n.defaultLocale = "en_GB.UTF-8";                                                                                                                         
                                                                                                                                                              
  # Enable the X11 windowing system.                                                                                                                          
  services.xserver.enable = true;                                                                                                                             
                                                                                                                                                              
  # Enable the GNOME Desktop Environment.                                                                                                                     
  services.xserver.displayManager.gdm.enable = true;                                                                                                          
  services.xserver.desktopManager.gnome.enable = true;                                                                                                        
                                                                                                                                                              
  # Configure keymap in X11                                                                                                                                   
  services.xserver.xkb = {                                                                                                                                    
    layout = "ch";                                                                                                                                            
    variant = "legacy";                                                                                                                                       
  };

  # Configure console keymap                                                                                                                 20:47:47 [39/593]
  console.keyMap = "sg";                                                                                                                                      
                                                                                                                                                              
  # Enable CUPS to print documents.                                                                                                                           
  services.printing.enable = true;                                                                                                                            
                                                                                                                                                              
  # Enable sound with pipewire.                                                                                                                               
  services.pulseaudio.enable = false;                                                                                                                         
  security.rtkit.enable = true;                                                                                                                               
  services.pipewire = {                                                                                                                                       
    enable = true;                                                                                                                                            
    alsa.enable = true;                                                                                                                                       
    alsa.support32Bit = true;                                                                                                                                 
    pulse.enable = true;                                                                                                                                      
    # If you want to use JACK applications, uncomment this                                                                                                    
    #jack.enable = true;                                                                                                                                      
                                                                                                                                                              
    # use the example session manager (no others are packaged yet so this is enabled by default,                                                              
    # no need to redefine it in your config for now)                                                                                                          
    #media-session.enable = true;                                                                                                                             
  };                                                                                                                                                          
                                                                                                                                                              
  # Enable touchpad support (enabled default in most desktopManager).                                                                                         
  # services.xserver.libinput.enable = true;                                                                                                                  
                                                                                                                                                              
  # Define a user account. Don't forget to set a password with ‘passwd’.                                                                                      
  users.users.david = {                                                                                                                                       
    isNormalUser = true;                                                                                                                                      
    description = "david";                                                                                                                                    
    extraGroups = [ "networkmanager" "wheel" ];                                                                                                               
    packages = with pkgs; [                                                                                                                                   
    #  thunderbird                                                                                                                                            
    ];                                                                                                                                                        
  };                                                                                                                                                          
                                                                                                                                                                                                                                                                                     
                                                                                                                                                              
  # List packages installed in system profile. To search, run:   
  # $ nix search wget                                                                                                                         20:47:47 [0/593]
  environment.systemPackages = with pkgs; [                                    
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.                                            
  #  wget
  helix                                
        git                                                                                                                              
  ];                         
  services.tailscale.enable = true;                                            
                            
                                  
  # Some programs need SUID wrappers, can be configured further or are                                                                                        
  # started in user sessions.
  # programs.mtr.enable = true;        
  # programs.gnupg.agent = {                                        
  #   enable = true;                   
  #   enableSSHSupport = true;
  # };                                                              
                                                                    
  # List services that you want to enable:                                     
                                  
  # Enable the OpenSSH daemon.                                      
   services.openssh.enable = true;                
   services.openssh.settings.PasswordAuthentication = true;
   fileSystems."/mnt/sda1" = {
      device = "/dev/disk/by-uuid/575abdac-97eb-4727-a4db-44c366b7da72";
      fsType = "ext4"; # or "vfat" / "ntfs" with appropriate options
      options = ["defaults" "nofail"];
    };

    fileSystems."/mnt/sba1" = {
      device = "/dev/disk/by-uuid/839e6d96-16ec-4529-9230-bfd74012a914";
      fsType = "ext4"; # or "vfat" / "ntfs" with appropriate options
      options = ["defaults" "nofail"];
    };
    fileSystems."/" =
    { device = "/dev/disk/by-uuid/e76d05b8-36c5-444f-aa91-68132f366396";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F6E5-B90F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/3e9fb390-fe73-4790-8e45-82065889d0fc";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/76bb8fdb-aba6-4626-afc4-d5ecc3ed60b7"; }
    ];
                                                                    
  # Open ports in the firewall.        
  # networking.firewall.allowedTCPPorts = [ ... ];                
  # networking.firewall.allowedUDPPorts = [ ... ];                                                                                       
  # Or disable the firewall altogether.                                                                                                  
  # networking.firewall.enable = false;                                                                                                  
                                                                                                                                         
  # This value determines the NixOS release from which the default                                                                       
  # settings for stateful data, like file locations and database versions                                                                                     
  # on your system were taken. It‘s perfectly fine and recommended to leave                                                                                   
  # this value at the release version of the first install of this system.                                                                                    
  # Before changing this value read the documentation for this option                                                                                         
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).         

}  