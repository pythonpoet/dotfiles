{config, lib,pkgs,  ...}: 
with lib; let 
  audiobookshelfDefaults = {

  };
  cfg = config.audiobookshelf // audiobookshelfDefaults;
  
in
{
  options.immich = {
    enable = mkEnableOption "Enable audiobookshelf server";
    data_dir = mkOption {
      type = types.str;
      default = "/mnt/sda1/audiobookshelf";
    };
    port = mkOption {
      type = types.port;
      default = 9981;
    };
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
  };
  config = mkIf cfg.enable {
     
  services.audiobookshelf = {
    enable = true;
    port = cfg.port;
    host = cfg.host;
    openFirewall = true;
    dataDir = cfg.data_dir;    
  };

  };

}
