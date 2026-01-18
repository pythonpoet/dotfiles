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
    
  };
  config = mkIf cfg.enable {
     
  services.onlyoffice = {
    enable = true;
    port = cfg.port;
    hostname = "localhost";
    postgresPasswordFile = config.age.secrets.onlyoffice.path;
  };

  };

}
