{ config, ... }:

{
  sops.secrets.frigate-environment = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    # emit the plain file instead of extracting a single key
    key = "";
    # automatically restart the service when secrets change
    restartUnits = [ "${config.virtualisation.oci-containers.backend}-frigate.service" ];
  };

  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:0.15.1";
    ports = [
      "5000:5000"
      "8971:8971"
      "8554:8554" # RTSP feeds
      # "8555:8555/tcp" # WebRTC over tcp
      # "8555:8555/udp" # WebRTC over udp
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/mnt/security-camera-recordings:/media/frigate"
      "frigate-config:/config"
      "type=tmpfs,dst=/tmp/cache,tmpfs-size=1000000000" # 1GB memory as cache
    ];
    devices = [
      "/dev/dri/renderD128" # for Intel hardware acceleration
    ];
    extraOptions = [
      "--shm-size=1024mb"
      # "--privileged"
    ];
  };
}
