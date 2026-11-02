# MinerU

Parse documents into Markdown / JSON with text, tables and formulas through the Gradio Web UI.

## Image and requirements

Upstream: https://github.com/opendatalab/MinerU
Documentation: https://opendatalab.github.io/MinerU/quick_start/docker_deployment/
Image: `windoze/mineru:latest`, a community build from https://github.com/windoze/mineru-docker, not an official image. The mutable tag was checked on 2026-11-02 and last updated on 2026-08-10; it does not imply the latest MinerU software release. Current official documentation builds `mineru:4` locally. This template does not build images.

Verified index digest: `sha256:df8535167794a0a6ca30e66f9f4816daf1686e2158b5e33340e3fb0b8d13be90`.
Linux amd64 / arm64; bundled models; approximately 13–14 GB compressed plus extraction and working space. Requires an NVIDIA GPU, a CUDA 13.0 compatible driver and NVIDIA Container Toolkit. VLM backends recommend at least 8 GB free VRAM; requirements vary. This template reserves one GPU and cannot install unchanged on CPU-only hosts.

## Setup

Verify `nvidia-smi` and Docker GPU support, sync local apps in 1Panel and install MinerU. Defaults: Web port 7860, host bind address `0.0.0.0`, NVIDIA GPU device ID `0`. Use `127.0.0.1` for a host-only reverse proxy. Open `http://HOST:7860`, upload a document and select a backend. Models are included in the image. Only the Web UI is started; no separate REST API service is launched. No login is configured: restrict access with a firewall or authenticated reverse proxy.

## Persistence and backup

`./data` in the app installation directory maps to `/data`; Gradio temporary files use `/data/gradio`. Temporary results may be cleaned; download important results. Models remain inside the image. Stop the app and back up `data` and deployment configuration; restore and restart.

## Validation

Image metadata and catalog configuration checked. Actual startup and parsing on 1Panel / NVIDIA hardware remain unverified. Logo: upstream `docs/images/MinerU-logo.png`, fitted to a 180×180 canvas.
