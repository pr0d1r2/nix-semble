# SPEC — nix-semble

## §G GOAL

Standalone Nix package for [semble](https://github.com/MinishLab/semble) — instant code search for any local or remote git repository. Full `buildPythonPackage` build (not uvx wrapper). Deps not in nixpkgs sourced from companion repos (nix-model2vec, nix-vicinity, nix-semble-grammars). Pre-built via cachix (`pr0d1r2.cachix.org`).

## §C CONSTRAINTS

- C1: Nix flake, nixpkgs follows `github:pr0d1r2/nixpkgs-lock` (fleet pin, currently `nixos-26.05`)
- C2: 4 systems: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- C3: Source pinned as `flake = false` input
- C4: Python build via `buildPythonPackage` — setuptools backend
- C5: 3 external dep flake inputs: nix-model2vec (>=0.10,<0.11), nix-vicinity, nix-semble-grammars. nixpkgs provides numpy, orjson, pathspec, questionary, tqdm
- C6: MCP extra (`mcp>=2.0,<3.0`) not packaged; nixpkgs has mcp 1.x. `semble install` writes agent MCP configs that run `uvx --from "semble[mcp]==<version>" semble`, so they need `uv` on the agent's PATH and fetch semble from PyPI. On NixOS, uvx's downloaded Python needs nix-ld, or `UV_PYTHON_DOWNLOADS=never` plus `UV_PYTHON` pointing at a Nix interpreter, with `LD_LIBRARY_PATH` for native wheels (nix-ld's `NIX_LD_LIBRARY_PATH` does not reach nixpkgs Python). Documented in README; this package does not bundle uv
- C7: Tests disabled — require model downloads
- C8: cachix binary cache in `nixConfig`
- C9: nix-lefthook single input for all CI tooling

## §I INTERFACES

- I.pkg: `packages.<system>.default` — semble Python package
- I.dev: `devShells.<system>.default` — dev environment w/ semble + linters
- I.flake-input: `inputs.nix-semble.url = "github:pr0d1r2/nix-semble"` w/ `nixpkgs.follows`
- I.run: `nix run github:pr0d1r2/nix-semble`

## §V VERSIONING

- semble version: pinned in semble.nix (currently 0.7.2)
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
