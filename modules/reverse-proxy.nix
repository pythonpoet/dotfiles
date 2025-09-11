{
  config,
  pkgs,
  ...
}: let
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
  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    #defaultSSLListenPort = 8080;

    virtualHosts = {
      "blog.chaosdam.net" = {
        inherit (sslSettings) addSSL enableACME;
        locations."/" = {
          root = pkgs.writeTextDir "index.html" ''
            <!DOCTYPE html>
            <html>
              <head><title>Welcome</title></head>
              <body><h1>Hello from NixOS!</h1></body>
            </html>
          '';
        };
      };
      "exdetail.chaosdam.net" = {
        inherit (sslSettings) addSSL enableACME; # Use the sslSettings variable
        locations."/" = {
          proxyPass = "http://hal:4004"; # Assuming your Phoenix app runs on port 4004
          proxyWebsockets = true; # If you need WebSocket support
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
