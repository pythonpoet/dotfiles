{
  conf,
  pkgs,
  ...
}: {
  virtualisation.oci-containers = {
    backend = "podman";
    containers.collabora = {
      image = "collabora/code";
      ports = ["9980:9980"];
      environment = {
        domain = "ocis.chaosdam.net";
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
      };
      extraOptions = ["--cap-add" "MKNOD"];
    };
  };
}
