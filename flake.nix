{
  description = "fufexan's NixOS and Home-Manager flake, Modified by pythonpoet";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        ./hosts
        ./hosts/deploy.nix
        ./lib
        ./modules
        ./pkgs
        ./fmt-hooks.nix
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nodePackages.prettier
            config.packages.repl
          ];
          name = "dots";
          DIRENV_LOG_FORMAT = "";
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };
      };
    };

  inputs = {
    # global, so they can be `.follow`ed
    systems.url = "github:nix-systems/default-linux";

    flake-compat.url = "github:edolstra/flake-compat";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/master";

    # rest of inputs, alphabetical order

    # agenix = {
    #   url = "github:ryantm/agenix";
    #   inputs = {
    #     #nixpkgs.follows = "nixpkgs";
    #     #home-manager.follows = "hm";
    #     #systems.follows = "systems";
    #     darwin.follows = "";
    #   };
    # };

    # ags = {
    #   url = "github:Aylur/ags";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    anyrun.url = "github:fufexan/anyrun/launch-prefix";
    deploy-rs.url = "github:serokell/deploy-rs";

    chaotic.url = "https://flakehub.com/f/chaotic-cx/nyx/*.tar.gz";

    helix.url = "github:helix-editor/helix";

    hm = {
      url = "github:pythonpoet/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko disk manager
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };

    uwu-colors = {
      url = "github:q60/uwu_colors";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    nixos-hardware = {
      url = "github:pythonpoet/nixos-hardware/master";
    };
    nixos-raspberrypi.url = "github:pythonpoet/nixos-raspberrypi/main";
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
  };
  nixConfig = {
  # extra-substituters = [
  #   "https://nixos-raspberrypi.cachix.org"
  # ];
  # extra-trusted-public-keys = [
  #   "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
  # ];
};
}
