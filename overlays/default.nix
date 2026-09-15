{ inputs }:

{
  ########## fixes / workarounds for problems not yet resolved upstream ###########################

  fixes = final: prev: {
    opencode = # TODO: https://github.com/NixOS/nixpkgs/issues/563241 , https://github.com/anomalyco/opencode/issues/48645 , https://discourse.nixos.org/t/opencode-server-error-workaround/80088
      let
        bun_1_3_13 = prev.bun.overrideAttrs (old: rec {
          version = "1.3.13";
          src = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-${
              {
                "x86_64-linux" = "linux-x64-baseline";
                "aarch64-linux" = "linux-aarch64";
                "aarch64-darwin" = "darwin-aarch64";
              }
              .${final.stdenv.hostPlatform.system}
            }.zip";
            hash =
              {
                "x86_64-linux" = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
                "aarch64-linux" = "sha256-cLrkGzkIsKEg4eWMXIrzDnSvrjuNEbDT/djnh937SyI=";
                "aarch64-darwin" = "sha256-VGfj9l26Umuf6pjwzOBO+vwMY+Fpcz7Ce4dqOtMtoZA=";
              }
              .${final.stdenv.hostPlatform.system};
          };
        });
      in
      inputs.nixpkgs.legacyPackages.${final.stdenv.hostPlatform.system}.opencode.override {
        bun = bun_1_3_13;
      };
  };

  ########## specific nixpkgs versions ############################################################

  pkgs-stable = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  pkgs-before-plasma5-drop = final: prev: {
    before-plasma5-drop = import inputs.nixpkgs-before-plasma5-drop {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  ########## my own libraries and packages ########################################################

  my-lib = final: prev: {
    my = prev.my or { } // {
      lib = prev.my.lib or { } // import ../lib { pkgs = final; };
    };
  };

  my-pkgs = final: prev: {
    my =
      prev.my or { }
      // import ../pkgs {
        inherit inputs;
        pkgs = final;
      };
  };

  ########## my own projects ######################################################################

  json2nix = final: prev: {
    my = prev.my or { } // {
      json2nix = inputs.json2nix.packages.${prev.stdenv.hostPlatform.system}.default;
    };
  };

  rambo = final: prev: {
    my = prev.my or { } // {
      rambo = inputs.rambo.packages.${prev.stdenv.hostPlatform.system}.default;
    };
  };

  ########## miscellaneous ########################################################################

  llm-agents = inputs.llm-agents.overlays.shared-nixpkgs;
}
