{ config, pkgs, ...}:{
services = {
    dnsmasq = {
      enable = true;
      extraConfig = ''
        interface=wg0
      '';
    };
  };
}
