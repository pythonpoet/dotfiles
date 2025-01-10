{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  db_user = "immich";
  db_name = "immich";
  db_pass = "postgres";
in {
  # Import the agenix module
  #imports = [inputs.agenix.nixosModules.default];

  # Ensure the postgresql group exists
  #users.groups.postgres_db = {};

  # Add the immich user to the postgresql group
  #users.users.immich = {
  #  isSystemUser = true;
  #  extraGroups = ["postgres_db"] ; # Add immich to the postgresql group
  #};

  #users.users.postgresql = {
  #  isSystemUser = true;
  #  group = "postgres_db";
  #};

  # Define the agenix secret
  #age.secrets.postgres-immich-password = {
  #  file = ../secrets/postgres-immich-password.age; # Path to the encrypted file
  #  owner = "immich"; # Ensure the postgres user can read the secret
  #  group = "postgres_db"; # Ensure the postgres group can read the secret
  #};

  services.postgresql = {
    enable = true;

    dataDir = "/mnt/sda1/databases";
    ensureDatabases = [db_name]; # Add the new data
    ensureUsers = [
      {
        name = db_user;
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];

    # Networking
    enableTCPIP = true;
    port = 5432;

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
}
