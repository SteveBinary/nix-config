{
  fileSystems."/mnt/security-camera-recordings" = {
    fsType = "nfs4";
    device = "192.168.100.10:/mnt/main-pool/security-camera-recordings";
    noCheck = true;
    options = [
      "auto"
      "_netdev"
      "rw"
      "nofail"
      "noatime"
      "nolock"
      "tcp"
      "actimeo=1800"
    ];
  };
}
