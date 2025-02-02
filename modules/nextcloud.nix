# https://codeberg.org/balint/nixos-configs/src/branch/main/hosts/vps/nextcloud.nix
{
  pkgs,
  lib,
  ...
}: let
  host_address = "192.168.0.26";
  local_address = "192.168.0.29";
  nexcloud_root = "/mnt/sda1/nextcloud";
  backup_folder = "/mnt/sdb1/backup/nextcloud";
  nextcloud_hostName = "cloud.chaosdam.net";
  admin_user = "david_wild@bluewin.ch";
in {
  # Reverse proxy for collabora
  #services.nginx.virtualHosts."${pconf.domain.collabora}" = {
  #  enableACME = true;
  #  forceSSL = true;
  #  locations."/" = {
  #    proxyPass = "http://localhost:9980";
  #    proxyWebsockets = true;
  #  };
  #};
  # Collabora CODE server in a container
  #virtualisation.oci-containers = {
  #  backend = "podman";
  #  containers.collabora = {
  #    image = "collabora/code";
  #    ports = ["9980:9980"];
  #    environment = {
  #      domain = "${pconf.domain.nextcloud}";
  #      extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
  #    };
  #    extraOptions = ["--cap-add" "MKNOD"];
  #  };
  #};
  # Reverse proxy for Nextcloud
  #services.nginx.virtualHosts."${pconf.domain.nextcloud}" = {
  #  enableACME = true;
  #  forceSSL = true;
  #  locations."/" = {
  #    proxyPass = "http://${guest_address}";
  #    proxyWebsockets = true;
  #    extraConfig = ''
  #      proxy_redirect http://$host https://$host;  # required for apps
  #    '';
  #  };
  #};

  networking = {
    bridges.br0.interfaces = ["end0"]; # Adjust interface accordingly

    # Get bridge-ip with DHCP
    useDHCP = false;
    interfaces."br0".useDHCP = true;

    # Set bridge-ip static
    interfaces."br0".ipv4.addresses = [
      {
        address = host_address;
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.0.1";
    nameservers = ["192.168.0.1"];
  };

  # Configure the container service itself
  systemd.services."container@nextcloud" = {
    serviceConfig = {
      TimeoutStartSec = lib.mkForce "30m";
      TimeoutStopSec = lib.mkForce "10m";
    };
  };
  # Automated backup service
  systemd.services.nextcloud-backup = {
    description = "Backup Nextcloud configuration and database";
    startAt = "04:00:00";
    path = with pkgs; [gnutar gzip findutils];
    script = ''
      find ${backup_folder} -name "backup_*.tar.gz" -mtime +14 -delete
      nixos-container run nextcloud -- sudo -u postgres pg_dumpall > db_dump.sql
      tar -czf "${backup_folder}/backup_$(date +\"%Y-%m-%d_%H-%M-%S\").tar.gz" config db_dump.sql
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Need root to access /persistent
      WorkingDirectory = nexcloud_root;
    };
  };
  # Nextcloud server in a container
  containers.nextcloud = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.0.29/24";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    bindMounts = {
      "/secrets" = {hostPath = "${nexcloud_root}/secrets";};
      "/var/lib/nextcloud/config" = {
        hostPath = "${nexcloud_root}/config";
        isReadOnly = false;
      };
      "/var/lib/nextcloud/data" = {
        hostPath = "${nexcloud_root}/data";
        isReadOnly = false;
      };
      "/var/lib/postgresql" = {
        hostPath = "${nexcloud_root}/db";
        isReadOnly = false;
      };
    };
    config = {
      pkgs,
      config,
      ...
    }: {
      networking.firewall.enable = false;
      #users.users.nextcloud.uid = 410517;  # Match the FUSE mount UID
      #users.groups.nextcloud.gid = 410517;
      systemd.services.phpfpm-nextcloud.serviceConfig.UMask = "0007";
      systemd.services.nginx.serviceConfig.UMask = lib.mkForce "0007";
      # Increase logging for update services
      systemd.services.nextcloud-setup.serviceConfig.LogLevelMax = "debug";
      systemd.services.nextcloud-update-db.serviceConfig.LogLevelMax = "debug";
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud30;
        hostName = nextcloud_hostName;
        https = true;
        maxUploadSize = "20G";
        configureRedis = true;
        database.createLocally = true;
        config = {
          dbtype = "pgsql";
          adminuser = admin_user;
          adminpassFile = "/secrets/pw";
        };
        settings = {
          trusted_proxies = [host_address];
          maintenance_window_start = 1;
          log_type = "file";
          #mail_smtpmode = "smtp";
          #mail_smtphost = pconf.mail.smtp;
          #mail_smtpport = 465;
          #mail_smtpsecure = "ssl";
          #mail_smtpauth = true;
          #mail_smtpname = pconf.mail.business;
          #mail_from_address = "cloud";
          #mail_domain = pconf.domain.business;
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "20";
        };
        appstoreEnable = true;
        extraAppsEnable = true;
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit
            bookmarks
            calendar
            #collectives
            
            contacts
            deck
            #drawio
            
            end_to_end_encryption
            forms
            groupfolders
            mail
            notes
            notify_push
            polls
            richdocuments
            # social
            
            tasks
            whiteboard
            # workspace
            
            ;
        };
      };
      system.stateVersion = "24.11";
    };
  };
}
