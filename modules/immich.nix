{
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/sda1/immich";

    # services.immich.secretsFile secretsFile for passwort

    environment = {
      IMMICH_HOST = "0.0.0.0";
      DB_HOSTNAME = "localhost"; # PostgreSQL host
      DB_PORT = "5432"; # PostgreSQL port
      DB_DATABASE_NAME = "immich"; # Database name
      DB_USERNAME = "immich"; # Database user
      DB_PASSWORD = "postgres";
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

}
