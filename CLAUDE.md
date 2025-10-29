# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Docker image build repository for llm-d development environments. It creates custom vLLM development images using the llm-d project's official Dockerfile, with automated nightly builds and efficient layered caching to enable fast custom builds.

## Architecture

The build system uses a two-layer approach to minimize rebuild times:

1. **Base Layer** (large, rebuilt nightly):
   - Built from `llm-d/docker/Dockerfile.cuda` (llm-d submodule)
   - Full compilation of vLLM with all dependencies
   - Tagged as `llm-d-dev:nightly`
   - Updated nightly to track latest vLLM main

2. **Checkout Layer** (small, <100MB, rebuilt per session):
   - Built from `./Dockerfile` which extends `llm-d-dev:nightly`
   - Clones vLLM repo and checks out `VLLM_CHECKOUT_COMMIT`
   - Uses `VLLM_USE_PRECOMPILED=1` to reuse compiled binaries from base layer
   - Only works for changes that don't require recompiling vLLM binaries (e.g., Python-only changes)

### Build Arguments

- `VLLM_CHECKOUT_COMMIT`: The specific vLLM commit to checkout for testing (used in quick builds)

### Git Remotes

The Dockerfile sets up multiple git remotes for vLLM:
- `vllm`: Official vLLM repository
- `njhill`: Nick Hill's fork
- `tms`: Taylor Smith's fork
- `nm`: Neural Magic's fork

## Common Commands

### Setting Up Nightly Builds

Enable automated nightly builds (runs at 2 AM):
```bash
./setup-cron.sh
```

This creates a cron job that:
- Fetches the latest vLLM main commit
- Updates `base_commit.txt` locally
- Builds from `llm-d/docker/Dockerfile.cuda`
- Tags locally as `llm-d-dev:nightly` and `llm-d-dev:nightly-<commit>`

### Manual Nightly Build

Manually trigger a nightly build (rebuilds the large base layer):
```bash
just nightly
```

### Building Custom Commits

Build and push an image for a specific vLLM commit (fast, uses cached base layer):
```bash
just build <commit-hash>
```

This:
- Uses `llm-d-dev:nightly` as the base image
- Clones vLLM and checks out `<commit-hash>`
- Installs with `VLLM_USE_PRECOMPILED=1` to reuse binaries from base
- Tags locally as `llm-d-dev:<commit-hash>`
- Pushes as `quay.io/tms/llm-d-dev:0.3.0-<commit-hash>`

**Note**: This only works for commits that don't require recompiling vLLM binaries (e.g., Python-only changes).

## Development Workflow

### Initial Setup
1. Run `./setup-cron.sh` once to enable nightly builds

### Per-Session Workflow
1. Wait for nightly build or run `just nightly` to update base layer
2. Run `just build <hash>` to build and push a custom commit image (couple minutes, <100MB layer)

### When Base Layer Needs Updating
The base layer is automatically updated nightly. To manually update:
1. Run `just nightly` to rebuild the base layer from latest vLLM main
2. Continue with normal `just build <hash>` workflow

## Important Notes

- `base_commit.txt` is gitignored and managed locally by nightly builds (tracks the vLLM commit in the base layer)
- The `llm-d` submodule contains the official llm-d Dockerfile used for base layer builds
- The entrypoint runs the vLLM OpenAI API server: `python -m vllm.entrypoints.openai.api_server`
- Quick builds clone vLLM to `/home/code/vllm` and set up multiple git remotes for easy development
