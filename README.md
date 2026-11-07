# nix-semble

<!-- hallucinogen:autonomy-disclaimer start -->
> Read [LLM-DISCLAIMER](docs/LLM-DISCLAIMER.md) first. This repository is
> tended by an autonomous loop, and that file says what the loop may do here,
> what it may not, and what to check before trusting anything in this tree.
<!-- hallucinogen:autonomy-disclaimer end -->

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

This package includes the `mcp` extra, with mcp 2.x from [nix-mcp-python-sdk](https://github.com/pr0d1r2/nix-mcp-python-sdk) (nixpkgs ships 1.x). Running `semble` with no subcommand starts the MCP server over stdio, exposing the `search` and `find_related` tools.

Install it into a profile (home-manager, nix-darwin, NixOS, or `nix profile install github:pr0d1r2/nix-semble`), then point an agent at the profile's binary, for example in Claude Code:

```json
{
  "mcpServers": {
    "semble": {
      "command": "/etc/profiles/per-user/<user>/bin/semble"
    }
  }
}
```

Use a profile path such as `/etc/profiles/per-user/<user>/bin/semble` or `~/.nix-profile/bin/semble`, not a raw `/nix/store/...` path. Those profile paths survive upgrades and garbage collection. A store path from `nix build` stays alive only while its `result` link or another GC root exists.

Prefer the default stdio transport. `semble --http` serves the same tools on a local port with no authentication, so any local user or process that can reach the port can search whatever the server user can read.

This flake needs nixpkgs `nixos-26.05` or newer (it follows nixpkgs-lock). nix-mcp-python-sdk builds httpx2 and httpcore2 2.16.0 from nixpkgs' recipes, which `nixos-25.11` lacks.

### `semble install`

`semble install` writes MCP entries that run `uvx --from "semble[mcp]==<version>" semble` instead of this binary. Those entries need [uv](https://github.com/astral-sh/uv) on the agent's PATH, and uvx fetches semble from PyPI. Configure the entry by hand, as above, to use this Nix build.

If you keep the uvx entries on NixOS, `uv` on PATH is not enough. By default uvx downloads a standalone Python, which cannot start without [nix-ld](https://github.com/nix-community/nix-ld); native wheels pulled from PyPI may also need library paths. Two setups work for the agent process:

- Enable `programs.nix-ld.enable = true;`, which lets uvx's downloaded Python and wheels run.
- Point uvx at a Nix Python instead: set `UV_PYTHON_DOWNLOADS=never` and `UV_PYTHON` to a Nix-provided interpreter, for example `${pkgs.python313}/bin/python3`. nixpkgs' Python is not loaded through nix-ld, so `NIX_LD_LIBRARY_PATH` does not apply to it. Wheels with native code then need `LD_LIBRARY_PATH` in the agent's environment, pointing at the Nix libraries they link against (for example `lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib pkgs.zlib ]`).

## Binary cache

semble is cached via [cachix](https://pr0d1r2.cachix.org). The flake includes `nixConfig` with the substituter, so `nix build` pulls pre-built binaries instead of compiling.

To accept the cache without prompts, add to `~/.config/nix/nix.conf`:

```ini
trusted-substituters = https://pr0d1r2.cachix.org
trusted-public-keys = pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=
```

## License

MIT
