{
  self,
  inputs,
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

    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    alpakabook = nixosSystem {
      system = "x86_64-linux";
      inherit specialArgs;
      modules =
        laptop
        ++ [
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
          {disabledModules = ["security/pam.nix"];}
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
      modules = [
        inputs.catppuccin.nixosModules.catppuccin
        ./alpakapi5
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"

        "${self}/modules/immich.nix"
        "${self}/modules/postgresql.nix"

        "${self}/modules/nextcloud.nix"
        "${self}/modules/owncloud.nix"

        "${self}/modules/reverse-proxy.nix"
        {
          home-manager = {
            users.david.imports = homeImports.server;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };

    alpakapi4 = nixosSystem {
      system = "aarch64-linux";
      inherit specialArgs;
      modules = [
        inputs.catppuccin.nixosModules.catppuccin
        ./alpakapi4
        #inputs.vscode-server.nixosModules.default

        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"

        #"${self}/modules/owncloud.nix"
        "${self}/modules/reverse-proxy.nix"
        "${self}/modules/wireguard.nix"
        "${self}/modules/legacy/dnsmasq.nix"
        {
          home-manager = {
            users.david.imports = homeImports."david@alpakapi4";
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
    hal = nixosSystem {
      inherit specialArgs;
      modules = [
        ./hal
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"

        "${self}/modules/owncloud.nix"
        "${self}/modules/vaultwarden.nix"
        "${self}/modules/borg.nix"
        "${self}/modules/vikunja.nix"
        "${self}/modules/ollama.nix"
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
          ocis = {
            enable = true;
            data_dir = "/var/lib/ocis/data";
            config_file = "/var/lib/ocis/config/ocis.yaml";
          };
          ollama = {
            enable = true;
            db_path = "/var/lib/ollama";
            models = [
              "deepseek-r1:1.5b"
              "deepseek-r1:8b"
              "deepseek-r1:14b"
            ];
          };
          #  networking.firewall.allowedTCPPorts =  [ 3456 ];
        }

        inputs.agenix.nixosModules.default
        inputs.chaotic.nixosModules.default
      ];
    };
  };
}
