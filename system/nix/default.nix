{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./nh.nix
    ./nixpkgs.nix
    ./substituters.nix

    # "${modulesPath}/virtualisation/oci-common.nix"
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/4d109af84c42f13500d34a878da86beff9482494/nixos/modules/virtualisation/oci-options.nix";
      sha256 = "sha256:06ydpyvibqnv5q92rxn4dqfsh425yy31c2iviajjxmadgzj9rlq4";
    })

    # Switches "armv8l" compatibility name to "armv7l"
    ./armv7l.nix
  ];

  # we need git for flakes
  environment.systemPackages = [pkgs.git];

  nix = let
    flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
  in {
    package = pkgs.lix;

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) flakeInputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      trusted-users = ["root" "@wheel"];
      #substituters = [ "https://cache.armv7l.xyz" ];
      #trusted-public-keys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];
      allowed-uris = [ "https://github.com/pythonpoet.keys" ];
    };
    
    buildMachines = [
    { hostName = "localhost";
      systems = [ "aarch64-linux" "armv7l-linux" ] ;
      supportedFeatures = [ "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 4;
      protocol = null;
    }
  ];
  };
  
}
