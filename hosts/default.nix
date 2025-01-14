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
    io = nixosSystem {
      inherit specialArgs;
      modules =
        laptop
        ++ [
          ./io
          "${mod}/core/lanzaboote.nix"

          "${mod}/programs/gamemode.nix"
          "${mod}/programs/hyprland.nix"
          "${mod}/programs/games.nix"

          "${mod}/network/spotify.nix"
          "${mod}/network/syncthing.nix"

          "${mod}/services/kanata"
          "${mod}/services/gnome-services.nix"
          "${mod}/services/location.nix"

          {
            home-manager = {
              users.mihai.imports = homeImports."mihai@io";
              extraSpecialArgs = specialArgs;
            };
          }

          # enable unmerged Howdy
          {disabledModules = ["security/pam.nix"];}
          "${howdy}/nixos/modules/security/pam.nix"
          "${howdy}/nixos/modules/services/security/howdy"
          "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"

          inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
        ];
    };

    alpakabook = nixosSystem {
      inherit specialArgs;
      modules =
        laptop
        ++ [
          # Include surface book specific configuration (only commons)
          inputs.nixos-hardware.nixosModules.microsoft-surface-common
          inputs.catppuccin.nixosModules.catppuccin
          ./alpakabook
          #"${mod}/core/lanzaboote.nix"

          "${mod}/programs/hyprland.nix"

          # "${mod}/network/spotify.nix"
          "${mod}/network/syncthing.nix"

          # "${mod}/services/kanata"
          "${mod}/services/gnome-services.nix"
          "${mod}/services/location.nix"

          {
            home-manager = {
              users.david.imports = homeImports."david@alpakabook";
              extraSpecialArgs = specialArgs;
            };
          }

          # # enable unmerged Howdy
          # {disabledModules = ["security/pam.nix"];}
          # "${howdy}/nixos/modules/security/pam.nix"
          # "${howdy}/nixos/modules/services/security/howdy"
          # "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"

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

        "${mod}/modules/immich.nix"
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
        # inputs.catppuccin.nixosModules.catppuccin
	  ./alpakapi4
	  #inputs.vscode-server.nixosModules.default

          "${mod}/core/users.nix"
          "${mod}/nix"
          "${mod}/programs/zsh.nix"
          "${mod}/programs/home-manager.nix"
{
   home-manager = {
		users.david.imports =  homeImports."david@alpakapi4";
    extraSpecialArgs = specialArgs;
		};
         }
#		({ config, pkgs, ... }: {
#          services.vscode-server.enable = true;
#        })
	];
	};
  };
}
