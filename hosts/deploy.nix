# ./hosts/deploy.nix
{
  flake.deploy = {
    nodes = {
      alpakapi5 = {
        hostname = "alpakapi5";  # Replace with actual hostname/IP
        buildHost = "david@hal";  # Build on your local machine
        profiles.system = {
          user = "david";
          path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.alpakapi5;
        };
      };
      
      # Add other nodes as needed
      hal = {
        hostname = "hal";
        buildHost = "localhost";
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hal;
        };
      };
    };
  };

  flake.checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
}