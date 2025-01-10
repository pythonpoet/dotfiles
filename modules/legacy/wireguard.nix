{ config, pkgs, ... }:
# see: https://nixos.wiki/wiki/WireGuard
# TODO: read this guid: https://www.procustodibus.com/blog/2020/11/wireguard-point-to-site-config/
{
  
  # Enable NAT
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "end0";
    internalInterfaces = [ "wg0" ];
  };
  # Open ports in the firewall
  networking.firewall = {
    allowedTCPPorts = [ 53 3000 8080 443 ];
    allowedUDPPorts = [ 53 51820 5335 ];
  };
 boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  networking.wg-quick.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP/IPv6 address and subnet of the client's end of the tunnel interface
      address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
      # The port that WireGuard listens to - recommended that this be changed from default
      listenPort = 51820 ;
      # Path to the server's private key
      privateKeyFile = "/home/david/wireguard-keys/private";

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postUp = ''
        ${pkgs.iptables}/bin/iptables -t mangle -A PREROUTING -i wg0 -j MARK --set-mark 0x30
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING ! -o wg0 -m mark --mark 0x30 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t mangle -A PREROUTING -i wg0 -j MARK --set-mark 0x30
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING ! -o wg0 -m mark --mark 0x30 -j MASQUERADE
      '';

      # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING -i wg0 -j MARK --set-mark 0x30
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING ! -o wg0 -m mark --mark 0x30 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -t mangle -D PREROUTING -i wg0 -j MARK --set-mark 0x30
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING ! -o wg0 -m mark --mark 0x30 -j MASQUERADE
      '';

      dns = ["10.0.0.1" "192.168.0.21" "0.0.0.0"];

      peers = [
        { # Fairphone4
          publicKey = "WiJOUq8OoajHULZVjLIOlgf1TP/fJQDH1fQB4oP32Xk=";
          presharedKey = "8LqO9VPELwS7eQDgw/QucGg8S/PXvb1/IOkr4nexI1Q=";
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
}

