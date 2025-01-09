{ config, pkgs, ... }:{
services.caddy = {
  enable = true;
  virtualHosts."cloud.david".extraConfig = ''
    reverse_proxy http://192.168.0.26:10081
  '';
  virtualHosts."another.example.org".extraConfig = ''
    reverse_proxy unix//run/gunicorn.sock
  '';
};
}
