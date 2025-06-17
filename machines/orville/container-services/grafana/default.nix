{ config, ... }:

{
  sops.secrets.grafana-environment = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    # emit the plain file instead of extracting a single key
    key = "";
    # automatically restart the service when secrets change
    restartUnits = [ "${config.virtualisation.oci-containers.backend}-grafana.service" ];
  };

  virtualisation.oci-containers.containers.grafana = {
    image = "docker.io/grafana/grafana-oss:12.0.1";
    environment = {
      TZ = "Europe/Berlin";
    };
    environmentFiles = [
      config.sops.secrets.grafana-environment.path
    ];
    ports = [
      "3000:3000"
    ];
    volumes = [
      "grafana-data:/var/lib/grafana"
    ];
  };
}
