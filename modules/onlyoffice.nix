{config, lib,pkgs,  ...}: 
with lib; let 
  onlyofficeDefaults = {

  };
  cfg = config.onlyoffice // onlyofficeDefaults;
  
in
{
  options.onlyoffice = {
    enable = mkEnableOption "Enable onlyoffice server";
    data_dir = mkOption {
      type = types.str;
      default = "/mnt/sda1/onlyoffice";
    };
    port = mkOption {
      type = types.port;
      default = 9989;
    };
    postgres_db_name = mkOption {
      type = types.str;
      default = "localhost";
    };
    postgres_db_database_name = mkOption {
      type = types.str;
      default = "onlyoffice";
    };
    postgres_db_user = mkOption {
      type = types.str;
      default = "onlyoffice";
    };
    postgres_db_pw = mkOption {
      type = types.str;
      default = "postgres";
    };
  };
  config = mkIf cfg.enable {
     
  services.onlyoffice = {
    enable = true;
    port = cfg.port;
    hostname = cfg.host;
    openFirewall = true;
    mediaLocation = cfg.data_dir;

    # services.immich.secretsFile secretsFile for passwort

    environment = {
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

  };

}
