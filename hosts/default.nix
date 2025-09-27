{
  self,
  inputs,
  stdenv,
  ...
}:
{
  flake.nixosConfigurations =
    let
      # shorten paths
      inherit (inputs.nixpkgs.lib) nixosSystem;

      howdy = inputs.nixpkgs-howdy;

      homeImports = import "${self}/home/profiles";

      mod = "${self}/system";
      # get the basic config to build on top of
      inherit (import mod) laptop;
      #inherit (import "${self}/modules/") _cloud;
      cloud = [
        "${self}/modules/owncloud.nix"
          "${self}/modules/vaultwarden.nix"
          "${self}/modules/borg.nix"
          "${self}/modules/vikunja.nix"
          "${self}/modules/incus.nix"
          "${self}/modules/exdetail/"
          "${self}/modules/ml/zonos.nix"
          "${self}/modules/ml/kokoro.nix"
          "${self}/modules/immich.nix"
          "${self}/modules/postgresql.nix"
          "${self}/modules/owncloud.nix"
          "${self}/modules/reverse-proxy.nix"
      ];

      # get these into the module system
      specialArgs = { inherit inputs self; };
    in
    {
      alpakapro = nixosSystem {
        system.stateVersion = 25.11;
        inherit specialArgs;
        modules = laptop ++ [
          # Include surface book specific configuration (only commons)
          inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
          inputs.catppuccin.nixosModules.catppuccin
          ./alpakapro
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
          { disabledModules = [ "security/pam.nix" ]; }
          "${howdy}/nixos/modules/security/pam.nix"
          "${howdy}/nixos/modules/services/security/howdy"
          "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"

          # inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
          inputs.disko.nixosModules.disko
        ];
      };

      alpakabook = nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = laptop ++ [
          # Include surface book specific configuration (only commons)
          inputs.nixos-hardware.nixosModules.microsoft-surface-common
          inputs.catppuccin.nixosModules.catppuccin
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
          { disabledModules = [ "security/pam.nix" ]; }
          "${howdy}/nixos/modules/security/pam.nix"
          "${howdy}/nixos/modules/services/security/howdy"
          "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"

          # inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
          inputs.disko.nixosModules.disko
        ];
      };

      alpakapi5 = nixosSystem {
        system = "aarch64-linux";
        inherit specialArgs;
        modules = cloud ++ [
          inputs.catppuccin.nixosModules.catppuccin
          ./alpakapi5
          "${mod}/core/users.nix"
          "${mod}/nix"
          "${mod}/programs/zsh.nix"
          "${mod}/programs/home-manager.nix"
          {
            home-manager = {
              users.david.imports = homeImports.server;
              extraSpecialArgs = specialArgs;
            };
            immich = {
              enable = true;
              data_dir = "/data1/immich";
            };
            postgresql = {
              enable = true;
              data_dir = "/data1/databases";
            }
          }

        ];
      };
      hal = nixosSystem {
        inherit specialArgs;
        system.stateVersion = 25.05;
        modules = [
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
            borg.enable = true;
            borg.startAt = "17:15:00";

            vikunja = {
              enable = true;
              db_path = "/var/lib/vikunja/db";
              files_path = "/var/lib/vikunja/files";
            };
            vaultwarden = {
              enable = true;
              data_dir = "/var/lib/vaultwarden";
            };
            cloud = {
              enable = true;
              enable_radicale = true;
              path_radicale = "/var/lib/radicale/";
              data_dir = "/var/lib/ocis/data";
              config_file = "/var/lib/ocis/config/ocis.yaml";
            };
            exDetail = {
              enable = true;
            };
            zonos.enable = true;
            llm = {
              enable = false;
              db_path = "/var/lib/ollama";
              models = [
                "deepseek-r1:1.5b"
                "deepseek-r1:8b"
                "deepseek-r1:14b"
              ];
            };
            incus = {
              enable = true;
              enable_networking = true;
            };
          }

          #inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
        ];
      };
    };
}
