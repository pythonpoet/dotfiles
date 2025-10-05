{config, lib, ...}: #test
with lib; let 
  immichDefaults = {

  };
  cfg = config.immich // immichDefaults;
  
  myOverlay = final: prev: {
    # Example: patch jemalloc for Raspberry Pi 5
    jemalloc = prev.jemalloc.overrideAttrs (old: {
      configureFlags =
        let
          pageSizeFlag = "--with-lg-page";
          filteredFlags = lib.filter (flag: !(lib.hasPrefix pageSizeFlag flag)) (old.configureFlags or []);
        in
          filteredFlags ++ [ "${pageSizeFlag}=14" ];
      meta = old.meta // {
        description = "${old.meta.description} (patched for 16 KB page size)";
      };
    });

    # Optional: override Python package to skip import check
    deepdiff = prev.deepdiff.overrideAttrs (old: {
      doCheck = false;
      checkPhase = ''
        echo "Skipping pythonImportsCheckPhase on Raspberry Pi 5"
      '';
    });
  };

 pkgsWithOverlay = import config.nixpkgs.pkgs {
  overlays = [ myOverlay ];
};
  
in
{
  options.immich = {
    enable = mkEnableOption "Enable immich server";
    data_dir = mkOption {
      type = types.str;
      default = "/mnt/sda1/immich";
    };
    port = mkOption {
      type = types.port;
      default = 9988;
    };
    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    postgres_db_name = mkOption {
      type = types.str;
      default = "localhost";
    };
    postgres_db_database_name = mkOption {
      type = types.str;
      default = "immich";
    };
    postgres_db_user = mkOption {
      type = types.str;
      default = "immich";
    };
    postgres_db_pw = mkOption {
      type = types.str;
      default = "postgres";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgsWithOverlay.jemalloc
      pkgsWithOverlay.deepdiff
    ];
    
  services.immich = {
    machine-learning.environment.MALLOC_CONF = "abort_conf:false";

    enable = true;
    port = cfg.port;
    host = cfg.host;
    openFirewall = true;
    mediaLocation = cfg.data_dir;

    # services.immich.secretsFile secretsFile for passwort

    environment = {
      MALLOC_CONF = "abort_conf:false";
      IMMICH_HOST = cfg.host;
      DB_HOSTNAME = cfg.postgres_db_name; # PostgreSQL host
      DB_PORT =  "${toString cfg.port}"; # PostgreSQL port
      DB_DATABASE_NAME = cfg.postgres_db_database_name; # Database name
      DB_USERNAME = cfg.postgres_db_user; # Database user
      DB_PASSWORD = cfg.postgres_db_pw;
      #DB_PASSWORD_FILE = config.age.secrets.postgres-immich-password.path; # Use agenix secret for the password
    };
  
    database.createDB = false;
    # Enable machine learning
    machine-learning.enable = true;
  };

  fileSystems."/mnt/sda1" = {
    device = "/dev/disk/by-uuid/575abdac-97eb-4727-a4db-44c366b7da72";
    fsType = "ext4"; # or "vfat" / "ntfs" with appropriate options
    options = ["defaults" "nofail" ];
  };

  fileSystems."/mnt/sba1" = {
    device = "/dev/disk/by-uuid/839e6d96-16ec-4529-9230-bfd74012a914";
    fsType = "ext4"; # or "vfat" / "ntfs" with appropriate options
    options = ["defaults" "nofail" ];
  };
  };

}
