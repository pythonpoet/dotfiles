{ config, pkgs, ... }:
# to make it more complicated: https://curiosum.com/blog/packaging-elixir-application-with-nix

{
   # Enable UPnP
  networking.firewall.allowedUDPPorts = [ 1900 ]; # UPnP discovery
  networking.firewall.allowPing = true;

  # Install packages
  environment.systemPackages = with pkgs; [
          erlang
          elixir_1_15
          nodejs_20
          inotify-tools
          miniupnpc
          nettools
         ];
      # Add a script to open ports
  systemd.services.upnp-port-forwarding = {
    description = "UPnP Port Forwarding";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    # Add Bash to the service's environment
    path = with pkgs; [
      bash       # Add Bash to the path
      nettools # Provides the `ifconfig` command
      gawk       # Provides the `awk` command
      miniupnpc
    ];
    script = ''
      #!/bin/bash
      IP=$(ifconfig | grep 'inet ' | awk '{print $2}' | head -n 1)
      if [ -z "$IP" ]; then
        echo "Error: Could not determine local IP address."
        exit 1
      fi

      echo "Local IP address: $IP"

      # Discover UPnP devices
      echo "Discovering UPnP devices..."
      upnpc -s

      # Add port mappings
      echo "Adding port mappings..."
      upnpc -a "$IP" 80 80 TCP || echo "Failed to forward port 80"
      upnpc -a "$IP" 443 443 TCP || echo "Failed to forward port 443"

      echo "Port forwarding complete."
  '';
  };
  # Postgres
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "ex_detail" ];
    enableTCPIP = true;
    port = 5432;
    authentication = pkgs.lib.mkOverride 10 ''
        #...
        #type database DBuser origin-address auth-method
        local all       all     trust
        # ipv4
        host  all      all     127.0.0.1/32   trust
        # ipv6
        host all       all     ::1/128        trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE postgres WITH LOGIN PASSWORD 'Spacco007' CREATEDB;
        CREATE DATABASE ex_detail;
        GRANT ALL PRIVILEGES ON DATABASE ex_detail TO postgres;
    '';
    };
    }