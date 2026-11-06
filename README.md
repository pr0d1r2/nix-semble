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

`semble install` configures coding agents with an MCP server entry that runs `uvx --from semble==<version> semble`. That entry needs [uv](https://github.com/astral-sh/uv) on the agent's PATH, and uvx fetches semble from PyPI instead of using this Nix build.

## Binary cache

semble is cached via [cachix](https://pr0d1r2.cachix.org). The flake includes `nixConfig` with the substituter, so `nix build` pulls pre-built binaries instead of compiling.

To accept the cache without prompts, add to `~/.config/nix/nix.conf`:

```ini
trusted-substituters = https://pr0d1r2.cachix.org
trusted-public-keys = pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=
```

## License

MIT
