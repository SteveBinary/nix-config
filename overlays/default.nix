{ inputs }:

{
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
  ddcutil-2-2-3 = final: prev: {
    # see: https://github.com/rockowitz/ddcutil/issues/581
    # This overlay should be obsolete once 2.2.6 is available.
    ddcutil = prev.ddcutil.overrideAttrs rec {
      version = "2.2.3";
      src = final.fetchurl {
        url = "https://www.ddcutil.com/tarballs/ddcutil-${version}.tar.gz";
        hash = "sha256-4XvAUqYvnqhS2eOLpPHtfnNmVnoOGdvhpDnuca2+BqA=";
      };
    };
  };
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
  json2nix = final: prev: {
    my = prev.my or { } // {
      json2nix = inputs.json2nix.packages."${prev.stdenv.hostPlatform.system}".default;
    };
  };
  rambo = final: prev: {
    my = prev.my or { } // {
      rambo = inputs.rambo.packages."${prev.stdenv.hostPlatform.system}".default;
    };
  };
}
