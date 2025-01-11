{ config, pkgs, ... }:
let
  email = "biobrotmithonig@gmail.com";
  extraConfig = ''
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  '';

  # Define SSL and ACME settings in a let variable
  sslSettings = {
    addSSL = true;
    enableACME = true;
  };
in {

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;

    virtualHosts = {
      #"exdetail.chaosdam.net" = {
      #  inherit (sslSettings) addSSL enableACME; # Use the sslSettings variable
      #  locations."/" = {
      #    proxyPass = "http://127.0.0.1:4004"; # Assuming your Phoenix app runs on port 4004
      #    proxyWebsockets = true; # If you need WebSocket support
      #    extraConfig = extraConfig;
      #  };
      #};

      "immich.chaosdam.net" = {
        inherit (sslSettings) addSSL enableACME; # Use the sslSettings variable
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283"; # Ensure Immich is accessible at this address
          proxyWebsockets = true;
          extraConfig = extraConfig;
        };
      };
      "cloud.chaosdam.net" = {
	      inherit (sslSettings) addSSL enableACME;
	      locations."/" = {
	        proxyPass = "http://192.168.0.29";
	        proxyWebsockets = true;
          extraConfig = extraConfig;
	      };
      };
      "ocis.chaosdam.net" = { 
        inherit (sslSettings) addSSL enableACME;
	      locations."/" = {
	      proxyPass = "https://192.168.0.26:9200";
	      proxyWebsockets = true;
	      extraConfig = extraConfig;
	      };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
  };
}
