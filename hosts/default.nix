{
  self,
  inputs,
  stdenv,
  config,
  ...
}: {
  flake.nixosConfigurations = let
    # shorten paths
    inherit (inputs.nixpkgs.lib) nixosSystem;

    howdy = inputs.nixpkgs-howdy;

    homeImports = import "${self}/home/profiles";

    mod = "${self}/system";
    # get the basic config to build on top of
    inherit (import mod) laptop;
    #inherit (import "${self}/modules/") _cloud;
    cloud = [
      "${self}/modules/ocis.nix"
      "${self}/modules/opencloud.nix"
      "${self}/modules/vaultwarden.nix"
      "${self}/modules/borg.nix"
      "${self}/modules/vikunja.nix"
      "${self}/modules/incus.nix"
      #"${self}/modules/exdetail/"
      "${self}/modules/ml/zonos.nix"
      "${self}/modules/ml/kokoro.nix"
      "${self}/modules/immich.nix"
      "${self}/modules/postgresql.nix"
      #"${self}/modules/owncloud.nix"
      "${self}/modules/reverse-proxy.nix"
      #"${self}/modules/jitsi.nix"
      "${self}/modules/audiobookshelf.nix"
      "${self}/modules/authenitk.nix"
      "${self}/modules/analytics.nix"
      #"${self}/modules/email.nix"
    ];

    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    alpakapro = nixosSystem {
      system = "x86_64-linux";
      inherit specialArgs;
      modules =
        laptop
        ++ [
          # Include surface book specific configuration (only commons)
          inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel

          ./alpakapro
          #"${mod}/core/lanzaboote.nix"
          "${self}/modules/fhs.nix"

          "${self}/home/programs/gnome/default.nix"

          # "${mod}/network/spotify.nix"
          "${mod}/network/syncthing.nix"

          # "${mod}/services/kanata"
          "${mod}/services/gnome-services.nix"
          "${mod}/services/location.nix"
          {
            home-manager = {
              #home.stateVersion = "24.11";
              backupFileExtension = ".hm-backup";
              users.david.imports = homeImports."david@alpakabook-gnome";
              extraSpecialArgs = specialArgs;
            };
          }

          # enable unmerged Howdy
          # {disabledModules = ["security/pam.nix"];}
          # "${howdy}/nixos/modules/security/pam.nix"
          # "${howdy}/nixos/modules/services/security/howdy"
          #"${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"

          # inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
          inputs.disko.nixosModules.disko
        ];
    };

    alpakabook = nixosSystem {
      system = "x86_64-linux";
      inherit specialArgs;
      modules =
        laptop
        ++ [
          # Include surface book specific configuration (only commons)
          inputs.nixos-hardware.nixosModules.microsoft-surface-common
          ./alpakabook
          #"${mod}/core/lanzaboote.nix"

          "${self}/home/programs/gnome/default.nix"

          # "${mod}/network/spotify.nix"
          "${mod}/network/syncthing.nix"

          # "${mod}/services/kanata"
          "${mod}/services/gnome-services.nix"
          "${mod}/services/location.nix"
          {
            home-manager = {
              #home.stateVersion = "24.11";
              users.david.imports = homeImports."david@alpakabook-gnome";
              extraSpecialArgs = specialArgs;
            };
          }

          # enable unmerged Howdy
          {disabledModules = ["security/pam.nix"];}
          "${howdy}/nixos/modules/security/pam.nix"
          "${howdy}/nixos/modules/services/security/howdy"
          "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"

          # inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
          inputs.disko.nixosModules.disko
        ];
    };
    
    bernina = inputs.nixos-raspberrypi.lib.nixosSystem{
      system = "aarch64-linux";
      specialArgs = {
        inherit inputs self;
        nixos-raspberrypi = inputs.nixos-raspberrypi; 
      };
      modules = cloud ++ [
        ./bernina
        inputs.agenix.nixosModules.default
        inputs.authentik.nixosModules.default
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"
        
         {
          age = {
            identityPaths= [
              "/home/david/.ssh/id_ed25519"
              "/root/.ssh/id_ed25519"
            ];
            secrets.borg.file = "/home/david/dotfiles/secrets/borg.age";
            secrets.vaultwarden.file = "/home/david/dotfiles/secrets/vaultwarden.age";
            secrets.authentik.file = "/home/david/dotfiles/secrets/authentik.age";
            secrets.maxmind-licence.file = "/home/david/dotfiles/secrets/maxmind-licence.age";

            secrets.vikunja-config = {
              file = "/home/david/dotfiles/secrets/vikunja-config.age";
              mode = "0440";
              group = "keys"; 
            };
          };
          home-manager = {
            users.david.imports = homeImports.server;
            extraSpecialArgs = specialArgs;
          };
          immich = {
            enable = true;
            data_dir = "/data1/immich/";
          };
          postgresql = {
            enable = true;
            data_dir = "/data1/databases";
          };
          reverse-proxy = {
            enable = true;
            geoip = {
              enable = true;
            };
          };
          cloud = {
            enable =true;
            data_dir = "/data1/opencloud/";
            enable_onlyoffice = true;
            enable_radicale = true;
            path_radicale = "/data1/radicale/";
            #config_file = "/data1/ocis/config/";
          };
          oldcloud = {
            enable =false;
            data_dir = "/data1/ocis/";
            config_file = "/data1/ocis/config/";
          };
          vikunja = {
            enable = true;
            db_path = "/data1/vikunja/db/vikunja.db";
            files_path = "/data1/vikunja/files";
            #secretConfigFile = age.secrets.vikunja-config.path;
          };
          vaultwarden = {
            enable = true;
            domain = "vault.davidwild.ch";
            data_dir = "/data1/vaultwarden";
          };
          # jitsi = {
          #   enable = false;
          #   domain = "jitsi.davidwild.ch";
          # };
          audiobookshelf = {
            enable = true;
            data_dir = "/data1/audiobookshelf";
          };
          #email.enable = true;
          authentik.enable = true;
          analytics = {
            enable = true;
          };
          borg = {
            enable = true;
            paths = [
                config.services.immich.mediaLocation
                "/data1/vaultwarden"
                "/data1/opencloud/"
                "/data1/vikunja/db/vikunja.db"
                "/data1/audiobookshelf"
              ];
            repo_host = "david@kaepfnach";
            repo_dir = "/data1/";
          };
        }
        
      ];
    };
    hal = nixosSystem {
      inherit specialArgs;
      system.stateVersion = 25.05;
      modules = cloud ++ [
        ./hal
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"

        {
          home-manager = {
            users.david.imports = homeImports."minimal";
            extraSpecialArgs = specialArgs;
          };
          postgresql = {
            enable = true;
            data_dir = "/backup/databases";
          };
        }
        
        #inputs.agenix.nixosModules.default
        inputs.chaotic.nixosModules.default
      ];
    };
    kaepfnach = nixosSystem {
      inherit specialArgs;
      system.stateVersion = 25.05;
      modules = cloud ++ [
        ./kaepfnach
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"

        {
          home-manager = {
            users.david.imports = homeImports."minimal";
            extraSpecialArgs = specialArgs;
          };
          postgresql = {
            enable = false;
            data_dir = "/backup/databases";
          };
        }
        
        inputs.chaotic.nixosModules.default
      ];
    };
  };
}
