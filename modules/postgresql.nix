{ config, pkgs, lib, ... }:
with lib;
let
  postgresDefaults = {
    db_user = "immich";
    db_names = ["immich"];
    db_pass = "postgres";
    db_port = 5432;
    data_dir = "/mnt/sda1/databases";
  };
  cfg = config.postgresql;
in {
  options.postgresql = {
    enable = mkEnableOption "Enable PostgreSQL with extensions";

    data_dir = mkOption {
      type = types.str;
      default = postgresDefaults.data_dir;
    };

    port = mkOption {
      type = types.port;
      default = postgresDefaults.db_port;
    };

    db_names = mkOption {
      type = types.listOf types.str;
      default = postgresDefaults.db_names;
    };

    db_user = mkOption {
      type = types.str;
      default = postgresDefaults.db_user;
    };

    db_pass = mkOption {
      type = types.str;
      default = postgresDefaults.db_pass;
    };
  };

  config = mkIf cfg.enable {
    
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;

      dataDir = cfg.data_dir;
      ensureDatabases = cfg.db_names;
      ensureUsers = [
        {
          name = cfg.db_user;
          ensureDBOwnership = true;
          ensureClauses = {
            login = true;
            #password = cfg.db_pass;
          };
        }
      ];

      enableTCPIP = true;
      authentication = mkOverride 10 ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';
      extensions = ps: [
          ps.pgvector
          ps.vectorchord
        ];
      settings = {
        port = cfg.port;
        shared_preload_libraries =   [ "vchord.so" ];
        search_path = "\"$user\", public, vectors";
      };
    };
    systemd.services.postgresql-setup.serviceConfig.ExecStartPost =
      let
        extensions = [
          "unaccent"
          "uuid-ossp"
          "cube"
          "earthdistance"
          "pg_trgm"
          "vector"
          "vchord"
        ];
        sqlFile = pkgs.writeText "immich-pgvectors-setup.sql" ''
          ${lib.concatMapStringsSep "\n" (ext: "CREATE EXTENSION IF NOT EXISTS \"${ext}\";") extensions}

          ALTER SCHEMA public OWNER TO ${cfg.db_user};
          ${lib.optionalString true "ALTER SCHEMA vectors OWNER TO ${cfg.db_user};"}
          GRANT SELECT ON TABLE pg_vector_index_stat TO ${cfg.db_user};

          ${lib.concatMapStringsSep "\n" (ext: "ALTER EXTENSION \"${ext}\" UPDATE;") extensions}
        '';
      in
      [
        ''
          ${lib.getExe' config.services.postgresql.package   "psql"} -d "immich" -f "${sqlFile}"
        ''
      ];
  };
}
