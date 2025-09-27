{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: with lib; let
  postgresDefaults = {
    db_user = "immich";
    db_names = ["immich"];
    db_pass = "postgres";
    db_port = 5432; 
    dataDir = "/mnt/sda1/databases";
  };
  cfg = config.postgresql;
in {
  options.postgresql =  {
     enable = lib.mkEnableOption "Enable Incus environment";

     data_dir = mkOption {
      type = types.str;
      default = postgresDefaults.dataDir;
    };
    port = mkOption {
      type = types.port;
      default = postgresDefaults.db_port;
    };

    db_names = mkOption {
      type = types.listOf types.str;
      default = postgresDefaults.db_names;
    };

    postgres_db_user = mkOption {
      type = types.str;
      default = postgresDefaults.db_user;
    };
    postgres_db_pw = mkOption {
      type = types.str;
      default = postgresDefaults.db_pass;
    };
  };
  config = mkIf cfg.enable {
  services.postgresql = {
    enable = true;

    dataDir = cfg.dataDir;
    ensureDatabases = cfg.db_names; # Add the new data
    ensureUsers = [
      {
        name = cfg.db_user;
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];

    # Networking
    enableTCPIP = true;
    port = cfg.port;

    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust
    '';

    # Plugins
    extraPlugins = ps: with ps; [pgvecto-rs];
    settings = {
      shared_preload_libraries = ["vectors.so"];
      search_path = "\"$user\", public, vectors";
    };
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE EXTENSION IF NOT EXISTS unaccent;
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS vectors;
      CREATE EXTENSION IF NOT EXISTS cube;
      CREATE EXTENSION IF NOT EXISTS earthdistance;
      CREATE EXTENSION IF NOT EXISTS pg_trgm;

      ALTER SCHEMA public OWNER TO ${db_user};
      ALTER SCHEMA vectors OWNER TO ${db_user};
      GRANT SELECT ON TABLE pg_vector_index_stat TO ${db_user};


      ALTER EXTENSION vectors UPDATE;
    '';
  };
  };
}
