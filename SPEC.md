# SPEC — nix-semble

## §G GOAL

Standalone Nix package for [semble](https://github.com/semble-dev/semble) — instant code search for any local or remote git repository. Full `buildPythonPackage` build (not uvx wrapper). Deps not in nixpkgs sourced from companion repos (nix-bm25s, nix-model2vec, nix-vicinity, nix-tree-sitter-language-pack). Pre-built via cachix (`pr0d1r2.cachix.org`).

## §C CONSTRAINTS

- C1: Nix flake, pinned `nixos-25.11`
- C2: 4 systems: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- C3: Source pinned as `flake = false` input
- C4: Python build via `buildPythonPackage` — setuptools backend
- C5: 4 external dep flake inputs: nix-bm25s, nix-model2vec, nix-vicinity, nix-tree-sitter-language-pack
- C6: tree-sitter-language-pack 1.8.1 exceeds semble's `<1.8.0` constraint — accepted (no breaking changes, constraint is conservative upper bound)
- C7: Tests disabled — require model downloads
- C8: cachix binary cache in `nixConfig`
- C9: nix-lefthook single input for all CI tooling

## §I INTERFACES

- I.pkg: `packages.<system>.default` — semble Python package
- I.dev: `devShells.<system>.default` — dev environment w/ semble + linters
- I.flake-input: `inputs.nix-semble.url = "github:pr0d1r2/nix-semble"` w/ `nixpkgs.follows`
- I.run: `nix run github:pr0d1r2/nix-semble`

## §V VERSIONING

- semble version: pinned in semble.nix (currently 0.3.1)
- Bump: update `semble-src` input URL tag + version in semble.nix + dep inputs

## §T TESTING

- T1: `nix flake check` — evaluates package + devShell for all systems
- T2: `pythonImportsCheck` validates import
- T3: lefthook pre-commit quality gates
- T4: three-platform CI via nix-lefthook-ci-action

## §B BUILD

- B1: `nix build` — builds semble for current system
- B2: `nix develop` — enters dev shell
- B3: cachix push: `nix build && cachix push pr0d1r2 result`
