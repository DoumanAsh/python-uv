# python-uv

[![Build](https://github.com/DoumanAsh/python-uv/actions/workflows/docker-image.yml/badge.svg)](https://github.com/DoumanAsh/python-uv/actions/workflows/docker-image.yml)
[![Hub](https://img.shields.io/badge/Docker-Hub-2496ed.svg)](https://hub.docker.com/r/douman/python-uv/tags)
[![Quay](https://img.shields.io/badge/quay.io-douman%2Fpython--uv-blue)](https://quay.io/repository/doumanash/python-uv)

Minimal docker image with `uv` and `python` installed

## Properties

- Entrypoint is `uv` executable
- Contains pre-installed python
- Non-root user
- Starting directly is `/app` and that's where you should mount your application

## Ways to use

- Mount `/app` with read+write permissions for `nonroot` user to access
- Build custom image using this one as baseline and copy  your application into `/app`
    - Optionally run `uv sync --locked --no-cache` to install dependencies before packaging your application
    - Override `ENTRYPOINT` to run your application instead of default `uv` entry point
