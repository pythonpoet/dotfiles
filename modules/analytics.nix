{
  config,
  self,
  lib,
  ...
}: 
with lib; let 
  cfg = config.analytics;
 in {
  options.analytics = {
    enable = mkEnableOption "Enable Analytics service";
    
    domain = mkOption {
      type = types.str;
      default = "grafana.davidwild.ch";
    };
    port = mkOption {
      type = types.port;
      default = 2342;
    };
    };

  config.analytics = mkIf cfg.enable {

  services.grafana = {
    enable = true;
    settings = {
      auth = {
        disable_login_form = false;
      };
      server = {
        http_addr = "127.0.0.1";
        http_port = cfg.port;
        enable_gzip = true;
        domain = cfg.domain;
        # The origin from which you are accessing Grafana.
        # You can specify multiple origins separated by a space or a comma.
        allow_embedding = true;
        allow_cors = true;
        cors_allow_origin = "*"; # Or a specific domain, e.g., "https://your-domain.com"
        cors_allow_headers = "accept, origin, content-type";
      };
      analytics.reporting_enabled = false;
    };
  };
  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
    };
  };
  
  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "alpakapi5";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = ["systemd"];
      port = 9002;
    };
  };

  services.loki = {
    enable = true;
    configFile = "${self}/modules/loki-local-config.yaml";
  };
  users.users.promtail.extraGroups = ["nginx"];
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://127.0.0.1:3100/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        # Systemd journal logs
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "alpakapi5";
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
        }

        # Nginx access logs (supports both old and new formats)]i
        # Nginx access logs
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = ["localhost"];
              labels = {
                # Keep only essential, low-cardinality labels
                job = "nginx";
                host = "alpakapi5";
                __path__ = "/var/log/nginx/access.log";
              };
            }
          ];
        }
      ];
    };
  };
  };
}
