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
    # nixpkgs.overlays = [
    #   (final: prev: {
    #     jemalloc = prev.jemalloc.overrideAttrs (old: {
    #       configureFlags =
    #         (lib.filter (flag: flag != "--with-lg-page=16") old.configureFlags)
    #         ++ [ "--with-lg-page=14" ];
    #     });

    #     folly = prev.folly.overrideAttrs (old: {
    #       env = (old.env or {}) // {
    #         NIX_CFLAGS_COMPILE =
    #           (old.env.NIX_CFLAGS_COMPILE or (old.NIX_CFLAGS_COMPILE or "")) 
    #           + " -Wno-array-bounds -Wno-stringop-overflow";
    #       };
    #       doCheck = false;
    #     });

    #     pgvecto-rs = prev.pgvecto-rs.overrideAttrs (old: {
    #       env = (old.env or {}) // {
    #         RUSTC_BOOTSTRAP = 1;
    #         JEMALLOC_SYS_WITH_LG_PAGE = "14";
    #       };
    #     });
    #   })
    # ];
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
      port = cfg.port;

      authentication = mkOverride 10 ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';
      extraPlugins = ps: with ps; [ pgvecto-rs ];
      settings = {
        shared_preload_libraries = [ "vectors.so" ];
        search_path = "\"$user\", public, vectors";
      };

      initialScript = pkgs.writeText "init.sql" ''
        CREATE EXTENSION IF NOT EXISTS unaccent;
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS vectors;
        CREATE EXTENSION IF NOT EXISTS cube;
        CREATE EXTENSION IF NOT EXISTS earthdistance;
        CREATE EXTENSION IF NOT EXISTS pg_trgm;

        ALTER SCHEMA public OWNER TO ${cfg.db_user};
        ALTER SCHEMA vectors OWNER TO ${cfg.db_user};
        GRANT SELECT ON TABLE pg_vector_index_stat TO ${cfg.db_user};

        ALTER EXTENSION vectors UPDATE;
      '';
    };
  };
}
