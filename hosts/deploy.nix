{ self, inputs, ... }:
{
  flake.deploy = {
    nodes = {

      bernina = {
        hostname = "bernina";  # Replace with actual hostname/IP
        profiles.system = {
          remoteBuild = true;
          user = "david";
          path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.bernina;
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
      alpakapro = {
        hostname = "alpakapro";
        buildHost = "localhost";
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.alpakapro;
        };
      };
    };
  };

  flake.checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
}