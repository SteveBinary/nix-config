{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.development.kubernetes;
in
{
  options.my.development.kubernetes = {
    enable = lib.mkEnableOption "Enable my Home Manager module for development with Kubernetes";
    setShellAliases = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kubecolor
      kubectl
      kubectx
      #kubelogin-oidc
      (kubelogin-oidc.overrideAttrs (
        finalAttrs: prevAttrs: {
          patches = (prevAttrs.patches or [ ]) ++ [
            # https://github.com/int128/kubelogin/pull/1558
            (pkgs.fetchpatch {
              name = "kubelogin-oidc-optional-id-token-with-access-token.diff";
              url = "https://github.com/int128/kubelogin/commit/321e4e657b72843ead3a313aeedab74041dabf90.diff?full_index=1";
              hash = "sha256-9hvMjdxWnKktykzWfZEGk5U07455mEKk85eF27JiiqM=";
            })
          ];
        }
      ))
      kubernetes-helm
      fluxcd
      minikube
    ];

    home.shellAliases = lib.optionalAttrs cfg.setShellAliases {
      k = "kubecolor";
      kx = "kubectx";
      kn = "kubens";
      kd = "k describe";
      kg = "k get";
      kga = "k get all";
      kgp = "k get pods";
      kgs = "k get services";
      kgn = "k get networkpolicies";
      kds = ''sh -c 'kubectl get secret "$@" -o json | jq ".data | map_values(@base64d)"' _'';
    };
  };
}
