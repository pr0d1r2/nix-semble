# nix-semble

[![CI](https://github.com/pr0d1r2/nix-semble/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-semble/actions/workflows/ci.yml)

Nix package for [semble](https://github.com/MinishLab/semble) — instant code search for any local or remote git repository. Pre-built binaries served via [cachix](https://pr0d1r2.cachix.org).

## Usage

### As a flake input

```nix
{
  inputs.nix-semble = {
    url = "github:pr0d1r2/nix-semble";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # In devShell packages:
  nix-semble.packages.${system}.default
}
```

### Direct run

```bash
nix run github:pr0d1r2/nix-semble
```

## MCP server

This package provides the `semble` CLI only. The `mcp` extra is not packaged, because it needs `mcp>=2.0` and nixpkgs has 1.x.

`semble install` configures coding agents with an MCP server entry that runs `uvx --from "semble[mcp]==<version>" semble`. That entry needs [uv](https://github.com/astral-sh/uv) on the agent's PATH, and uvx fetches semble from PyPI instead of using this Nix build.

On NixOS, `uv` on PATH is not enough. By default uvx downloads a standalone Python, which cannot start without [nix-ld](https://github.com/nix-community/nix-ld); native wheels pulled from PyPI may also need library paths. Two setups work for the agent process:

- Enable `programs.nix-ld.enable = true;`, which lets uvx's downloaded Python and wheels run.
- Point uvx at a Nix Python instead: set `UV_PYTHON_DOWNLOADS=never` and `UV_PYTHON` to a Nix-provided interpreter, for example `${pkgs.python313}/bin/python3`. nixpkgs' Python is not loaded through nix-ld, so `NIX_LD_LIBRARY_PATH` does not apply to it. Wheels with native code then need `LD_LIBRARY_PATH` in the agent's environment, pointing at the Nix libraries they link against (for example `lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib pkgs.zlib ]`).

[nix-mcp-python-sdk](https://github.com/pr0d1r2/nix-mcp-python-sdk) packages mcp 2.x, which lets a future version of this package run the MCP server from the Nix build with no uvx at all.

## Binary cache

semble is cached via [cachix](https://pr0d1r2.cachix.org). The flake includes `nixConfig` with the substituter, so `nix build` pulls pre-built binaries instead of compiling.

To accept the cache without prompts, add to `~/.config/nix/nix.conf`:

```ini
trusted-substituters = https://pr0d1r2.cachix.org
trusted-public-keys = pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=
```

## License

MIT
