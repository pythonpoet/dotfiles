{config, lib,pkgs,  ...}: 
with lib; let 
  audiobookshelfDefaults = {

  };
  cfg = config.audiobookshelf // audiobookshelfDefaults;
  
in
{
  options.audiobookshelf = {
    enable = mkEnableOption "Enable audiobookshelf server";
    data_dir = mkOption {
      type = types.str;
      default = "/data1/audiobookshelf";
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
  # Ensure /data1/audiobookshelf exists with correct permissions
  systemd.tmpfiles.rules = [
      "d ${cfg.data_dir} 0750 audiobookshelf audiobookshelf -"
      "L+ /var/lib/audiobookshelf - - - - ${cfg.data_dir}"
    ];

  # Ensure the service starts after the mount point is available
  systemd.services.audiobookshelf.unitConfig.RequiresMountsFor = [ "/data1" ];

  };

}
