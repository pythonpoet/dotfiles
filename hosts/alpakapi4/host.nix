{ config, pkgs, ... }:
# see: https://nixos.wiki/wiki/WireGuard
# see: https://tailscale.com/blog/nixos-minecraft

{
  # Install packages
  environment.systemPackages = [ 
	  pkgs.wireguard-tools
	  pkgs.tailscale
	 ];
  # Enable NAT
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "end0";
    internalInterfaces = [ "wg0" ];
  };
  # Open ports in the firewall
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 51820 ];
  };
  networking.wg-quick.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP/IPv6 address and subnet of the client's end of the tunnel interface
      address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
      # The port that WireGuard listens to - recommended that this be changed from default
      listenPort = 51820;
      # Path to the server's private key
      privateKeyFile = "/home/david/wireguard-keys/private";

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
      '';

      # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
      '';

      peers = [
        { # Fairphone4
          publicKey = "WiJOUq8OoajHULZVjLIOlgf1TP/fJQDH1fQB4oP32Xk=";
          presharedKeyFile = "/home/david/wireguard-keys/preshared-fairphone4";
          allowedIPs = [ "10.0.0.2/32" "fdc9:281f:04d7:9ee9::2/128" ];
        }
        {
	  publicKey = "5dng8nyoWgKOfW2fNI7rlLP4IxtBcv1Fm6j+V03ueSc=";
	  presharedKey = "skhDE/mHq5pCgiy5bLqV2UpjIQ8Abih6RS3ZeYUHtno=";
	  allowedIPs = ["10.0.0.3/32"];
	}
	# More peers can be added here.
      ];
    };
  };
  services = {
    dnsmasq = {
      enable = true;
      extraConfig = ''
        interface=wg0
      '';
    };
  };
# configure Tailscale
  # enable the tailscale service
  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2.

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey tskey-auth-khNM44NFED11CNTRL-MCMJfRn8gP81M9sToshwP8gToe4abXgM
    '';
  }; 
  }

