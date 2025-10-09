# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Docker image build repository for llm-d development environments. It creates custom vLLM development images based on the `llm-d-cuda-dev` base image, with automated nightly builds and efficient layered caching to enable fast custom builds.

## Architecture

The build system uses a two-layer approach to minimize rebuild times:

1. **Base Layer** (large, ~8.5GB, rebuilt nightly):
   - Uses `ghcr.io/llm-d/llm-d-cuda-dev:latest`
   - Installs vLLM at `VLLM_BASE_COMMIT` with compiled binaries
   - Updated nightly to track latest vLLM main

2. **Checkout Layer** (small, <100MB, rebuilt per session):
   - Checks out `VLLM_CHECKOUT_COMMIT` without reinstalling
   - Uses `VLLM_USE_PRECOMPILED=1` to reuse base layer binaries
   - Only works for changes that don't require recompiling vLLM binaries

### Build Arguments

- `VLLM_BASE_COMMIT`: The vLLM commit where binaries are compiled (stored in `base_commit.txt`, updated by nightly builds)
- `VLLM_CHECKOUT_COMMIT`: The specific commit to checkout for testing (defaults to `VLLM_BASE_COMMIT`)

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
- Builds and pushes to `quay.io/tms/llm-d-dev:latest`
- Caches locally as `llm-d-dev:nightly`

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
- Uses the base commit from `base_commit.txt`
- Checks out `<commit-hash>` in the small checkout layer
- Tags and pushes as `quay.io/tms/llm-d-dev:0.3.0-<commit-hash>`

**Note**: This only works for commits that don't require recompiling vLLM binaries (e.g., Python-only changes).

## Development Workflow

### Initial Setup
1. Run `./setup-cron.sh` once to enable nightly builds

### Per-Session Workflow
1. Wait for nightly build or run `just nightly` to update base layer
2. Run `just build <hash>` to build and push a custom commit image (couple minutes, <100MB layer)

### When Base Layer Needs Updating
If you need to update the base layer manually (e.g., to test a different base commit):
1. Edit `base_commit.txt` with the desired commit hash
2. Run `just nightly` to rebuild the base layer
3. Continue with normal `just build <hash>` workflow

## Important Notes

- `base_commit.txt` is gitignored and managed locally by nightly builds
- The entrypoint runs the vLLM OpenAI API server: `/opt/vllm/bin/python -m vllm.entrypoints.openai.api_server`
