# SPEC — nix-semble

## §G GOAL

Standalone Nix package for [semble](https://github.com/MinishLab/semble) — instant code search for any local or remote git repository. Full `buildPythonPackage` build (not uvx wrapper). Deps not in nixpkgs sourced from companion repos (nix-model2vec, nix-vicinity, nix-semble-grammars). Pre-built via cachix (`pr0d1r2.cachix.org`).

## §C CONSTRAINTS

- C1: Nix flake, nixpkgs follows `github:pr0d1r2/nixpkgs-lock` (fleet pin, currently `nixos-26.05`)
- C2: 4 systems: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- C3: Source pinned as `flake = false` input
- C4: Python build via `buildPythonPackage` — setuptools backend
- C5: 4 external dep flake inputs: nix-model2vec (>=0.10,<0.11), nix-vicinity, nix-semble-grammars, nix-mcp-python-sdk (mcp >=2.0,<3.0). nixpkgs provides numpy, orjson, pathspec, questionary, tqdm
- C6: MCP extra included: mcp 2.x from nix-mcp-python-sdk (nixpkgs has 1.x). Bare `semble` runs the MCP server over stdio. `semble install` still writes uvx-based entries (`uvx --from "semble[mcp]==<version>" semble`), which bypass this build; README documents a hand-written entry pointing at the Nix binary, plus the NixOS setup the uvx entries need (nix-ld, or `UV_PYTHON_DOWNLOADS=never` + `UV_PYTHON` + `LD_LIBRARY_PATH`)
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
