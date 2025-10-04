{
  self,
  inputs,
  stdenv,
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
      "${self}/modules/owncloud.nix"
      "${self}/modules/vaultwarden.nix"
      "${self}/modules/borg.nix"
      "${self}/modules/vikunja.nix"
      "${self}/modules/incus.nix"
      #"${self}/modules/exdetail/"
      "${self}/modules/ml/zonos.nix"
      "${self}/modules/ml/kokoro.nix"
      "${self}/modules/immich.nix"
      "${self}/modules/postgresql.nix"
      "${self}/modules/owncloud.nix"
      "${self}/modules/reverse-proxy.nix"
      "${self}/modules/jitsi.nix"
    ];

    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    alpakapro = nixosSystem {
      system.stateVersion = 25.11;
      inherit specialArgs;
      modules =
        laptop
        ++ [
          # Include surface book specific configuration (only commons)
          inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
          inputs.catppuccin.nixosModules.catppuccin
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
    alpakapi5 = nixosSystem{
      specialArgs = inputs;
      system = "aarch64-linux";
      modules = [
        ./alpakapi5
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"

        ];
    };
    bernina = inputs.nixos-raspberrypi.lib.nixosSystemFull {
      system = "aarch64-linux";
      specialArgs = { inherit inputs self; };
      modules = [
        ./bernina
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
        }
        #inputs.agenix.nixosModules.default
        inputs.chaotic.nixosModules.default
      ];
    };
  };
}
