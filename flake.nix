{
  description = "Nix package for semble — instant code search for any git repository";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    semble-src = {
      url = "github:MinishLab/semble/v0.3.1";
      flake = false;
    };
    nix-lefthook = {
      url = "github:pr0d1r2/nix-lefthook";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-bm25s = {
      url = "github:pr0d1r2/nix-bm25s";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-model2vec = {
      url = "github:pr0d1r2/nix-model2vec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-tree-sitter-language-pack = {
      url = "github:pr0d1r2/nix-tree-sitter-language-pack";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nix-bm25s,
      nix-model2vec,
      nix-tree-sitter-language-pack,
      nix-vicinity,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
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
          bm25s = nix-bm25s.packages.${sys}.default;
          model2vec = nix-model2vec.packages.${sys}.default;
          tree-sitter-language-pack = nix-tree-sitter-language-pack.packages.${sys}.default;
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
