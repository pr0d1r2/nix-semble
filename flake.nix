{
  description = "Nix package for semble — instant code search for any git repository";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    semble-src = {
      url = "github:MinishLab/semble/v0.7.2";
      flake = false;
    };
    nix-lefthook = {
      url = "github:pr0d1r2/nix-lefthook";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-model2vec = {
      url = "github:pr0d1r2/nix-model2vec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-semble-grammars = {
      url = "github:pr0d1r2/nix-semble-grammars";
      inputs = {
        nixpkgs-lock.follows = "nixpkgs-lock";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-mcp-python-sdk = {
      url = "github:pr0d1r2/nix-mcp-python-sdk";
      inputs = {
        nixpkgs-lock.follows = "nixpkgs-lock";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-vicinity = {
      url = "github:pr0d1r2/nix-vicinity";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      semble-src,
      nix-lefthook,
      nix-model2vec,
      nix-semble-grammars,
      nix-mcp-python-sdk,
      nix-vicinity,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
      depsFor =
        pkgs:
        let
          sys = pkgs.stdenv.hostPlatform.system;
        in
        {
          model2vec = nix-model2vec.packages.${sys}.default;
          semble-grammars = nix-semble-grammars.packages.${sys}.default;
          mcp = nix-mcp-python-sdk.packages.${sys}.mcp;
          vicinity = nix-vicinity.packages.${sys}.default;
        };
    in
    {
      packages = forAllSystems (pkgs: {
        default = import ./semble.nix {
          inherit pkgs;
          src = semble-src;
          deps = depsFor pkgs;
        };
      });

      devShells = forAllSystems (pkgs: {
        ci = pkgs.mkShell {
          inputsFrom = [ nix-lefthook.devShells.${pkgs.stdenv.hostPlatform.system}.ci ];
          packages = [
            (import ./semble.nix {
              inherit pkgs;
              src = semble-src;
              deps = depsFor pkgs;
            })
          ];
        };

        default = pkgs.mkShell {
          inputsFrom = [ nix-lefthook.devShells.${pkgs.stdenv.hostPlatform.system}.ci ];
          packages = [
            (import ./semble.nix {
              inherit pkgs;
              src = semble-src;
              deps = depsFor pkgs;
            })
          ];
          shellHook = builtins.readFile ./dev.sh;
        };
      });
    };
}
