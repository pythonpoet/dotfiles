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
      extensions =
        ps:
        lib.optionals cfg.database.enableVectors [ ps.pgvecto-rs ]
        ++ lib.optionals cfg.database.enableVectorChord [
          ps.pgvector
          ps.vectorchord
        ];
      settings = {
        shared_preload_libraries =
           [
            "vectors.so"
          ]
          ++  [ "vchord.so" ];
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
        ]
        ++ [
          "vectors"
        ]
        ++  [
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
          ${lib.getExe' postgresqlPackage "psql"} -d "immich" -f "${sqlFile}"
        ''
      ];
  };
}
