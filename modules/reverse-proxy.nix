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
    proxy_set_header X-Request-Id $request_id; # Add X-Request-Id header
  '';

  # Define SSL and ACME settings in a let variable
  sslSettings = {
    addSSL = true;
    enableACME = true;
  };
  # Package the ngx_http_geoip2_module from its Git repository
  # thix to https://joseph-long.com/writing/website-analytics-with-nixos/
  ngx_http_geoip2_module = pkgs.fetchFromGitHub {
    owner = "leev";
    repo = "ngx_http_geoip2_module";
    rev = "445df24ef3781e488cee3dfe8a1e111997fc1dfe";
    # The sha256 hash must be correct. You can get the correct hash by setting this to ""
    # and running `nixos-rebuild switch`, then copying the hash from the error message.
    sha256 = "sha256-aO+ff+3fQ9FJgjkVdWUqsSS6ctHq/TXvyGRasW6fXcA=";
  };
in {
  environment.systemPackages = [pkgs.geoip];
  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.overrideAttrs (oldAttrs: {
      # Add the module as a build-time dependency
      configureFlags = oldAttrs.configureFlags ++ ["--add-module=${ngx_http_geoip2_module}"];
      # The `libmaxminddb` library is required for the module to build
      buildInputs = oldAttrs.buildInputs ++ [pkgs.libmaxminddb];
    });

    appendHttpConfig = ''
        geoip2 /var/lib/nginx/geoip/GeoLite2-Country.mmdb {
          auto_reload 5m;
          $geoip2_metadata_country_build metadata build_epoch;
          $geoip2_data_country_code country iso_code;
          $geoip2_data_country_name country names en;
          $geoip2_data_continent_code continent code;
          $geoip2_data_continent_name continent names en;
        }

        geoip2 /var/lib/nginx/geoip/GeoLite2-City.mmdb {
            auto_reload 5m;
            $geoip2_data_city_name city names en;
            $geoip2_data_lat location latitude;
            $geoip2_data_lon location longitude;
        }

        geoip2 /var/lib/nginx/geoip/GeoLite2-ASN.mmdb {
            auto_reload 5m;
            $geoip2_data_asn autonomous_system_number;
            $geoip2_data_asorg autonomous_system_organization;
        }
        map $host$request_uri $full_request_path {
          default "$host$request_uri";
      }
        # Custom log format using GeoIP variables
        log_format json_combined escape=json '{'
          '"remote_addr":"$remote_addr",'
          '"remote_user":"$remote_user",'
          '"time_local":"$time_local",'
          '"request_method":"$request_method",'
          '"request_path":"$request_uri",'
          '"full_request_path":"$full_request_path",'
          '"request_domain":"$host",'
          '"status":$status,'
          '"bytes_sent":$body_bytes_sent,'
          '"http_referer":"$http_referer",'
          '"http_user_agent":"$http_user_agent",'
          '"country_code":"$geoip2_data_country_code",'
          '"city_name":"$geoip2_data_city_name",'
          '"continent_code":"$geoip2_data_continent_code",'
          '"continent_name":"$geoip2_data_continent_name",'
          '"asn":"$geoip2_data_asn",'
          '"asorg":"$geoip2_data_asorg",'
          '"lat":"$geoip2_data_lat",'
          '"lon":"$geoip2_data_lon"'
        '}';

        # Use the new JSON log format
        access_log /var/log/nginx/access.log json_combined;
        fastcgi_param MM_CONTINENT_CODE $geoip2_data_continent_code;
        fastcgi_param MM_CONTINENT_NAME $geoip2_data_continent_name;
        fastcgi_param MM_COUNTRY_CODE $geoip2_data_country_code;
        fastcgi_param MM_COUNTRY_NAME $geoip2_data_country_name;
        fastcgi_param MM_CITY_NAME    $geoip2_data_city_name;
        fastcgi_param MM_LATITUDE $geoip2_data_lat;
        fastcgi_param MM_LONGITUDE $geoip2_data_lon;
        fastcgi_param MM_ISP $geoip2_data_asorg;
    '';
    virtualHosts = {
      "grafana.davidwild.ch" = {
        inherit (sslSettings) addSSL enableACME;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
          extraConfig = extraConfig;
        };
      };
      "davidwild.ch" = {
        inherit (sslSettings) addSSL enableACME;
        locations."/" = {
          extraConfig = extraConfig;
          # Serve a simple Hello World page
          root = pkgs.writeTextDir "index.html" ''
             <!DOCTYPE html>
              <html>
                <head>
                <meta charset="UTF-8">
              <title>David Wild</title>
              </head>
            <body>
              <h1>Grüezi! 👋</h1>

              <p>Dear Bots, wanna-be artificial intelligences and also humans:
                <br>
               -> welcome to my Website!
                <br>
              I'm David Wild, and I'm a emancipated programmer from Zürich, Switzerland.
                <br>
              I like to do interdisciplinary work, ranging from rather technical topics like embedded engineering, software design or datascience to social research and doing art.
              <br>
              soon to be continued ..
              </p>
            </body>
            </html>
          '';
        };
        locations."/geoip-test" = {
          # This location will only be used for testing.
          # We use a literal string to return a JSON object with the GeoIP data.
          return = "200 '{ \"country_code\": \"$geoip2_data_country_code\", \"city_name\": \"$geoip2_data_city_name\", \"asn\": \"$geoip2_data_asn\", \"as_org\": \"$geoip2_data_asorg\" }'";
        };
        locations."/robots.txt" = {
          extraConfig = ''
            rewrite ^/(.*)  $1;
            return 200 "User-agent: *\nDisallow: /";
          '';
        };
      };
      "immich.davidwild.ch" = {
        inherit (sslSettings) addSSL enableACME; # Use the sslSettings variable
        locations."/" = {
          proxyPass = "http://badenerstrasse:2283"; # Ensure Immich is accessible at this address
          proxyWebsockets = true;
          extraConfig = extraConfig;
        };
      };

      "cloud.davidwild.ch" = {
        inherit (sslSettings) addSSL enableACME;
        locations."/" = {
          proxyPass = "https://badenerstrasse:9200";
          proxyWebsockets = true;
          extraConfig = extraConfig;
        };
      };
      "bbcs-121-149.pub.wingo.ch" = {
        locations."/" = {
          return = 444;
        };
        # Enable SSL for this server block if needed
        inherit (sslSettings) addSSL enableACME;
        # forceSSL = true;
      };

      # Blocking for IP address 144.2.121.149
      "144.2.121.149" = {
        locations."/" = {
          return = 444;
        };
        # inherit (sslSettings) addSSL;
        #forceSSL = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
  };

  services.geoipupdate = {
    enable = true;
    interval = "weekly";
    settings = {
      AccountID = 1221193; # Replace with your MaxMind Account ID
      EditionIDs = ["GeoLite2-City" "GeoLite2-Country" "GeoLite2-ASN"]; #-> network information
      # Use a secret to store your license key
      LicenseKey = {
        _secret = "/run/keys/maxmind-licence_key";
      };
      # Specify the directory where the databases will be stored
      DatabaseDirectory = "/var/lib/nginx/geoip";
    };
  };
}
