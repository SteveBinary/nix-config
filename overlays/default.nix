{ inputs }:

{
  ########## fixes ################################################################################

  fixes = final: prev: {
    # remove when fixed: https://github.com/NixOS/nixpkgs/issues/513245
    openldap = prev.openldap.overrideAttrs {
      doCheck = !prev.stdenv.hostPlatform.isi686;
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
      json2nix = inputs.json2nix.packages."${prev.stdenv.hostPlatform.system}".default;
    };
  };

  rambo = final: prev: {
    my = prev.my or { } // {
      rambo = inputs.rambo.packages."${prev.stdenv.hostPlatform.system}".default;
    };
  };

  ########## miscellaneous ########################################################################

  llm-agents = inputs.llm-agents.overlays.default;
}
