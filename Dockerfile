# Download uv/python
ARG DEBIAN_VERSION=trixie
FROM docker.io/debian:$DEBIAN_VERSION-slim as builder

ARG UV_VERSION=latest
ARG PYTHON_VERSION=3.15

ENV PATH=/usr/local/bin/:$PATH \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_PREFERENCE=only-managed \
    UV_NO_MODIFY_PATH=1 \
    UV_PRINT_QUIET=1

RUN set -xe ;\
    apt-get update ;\
    apt-get install -y binutils curl ;\
    case "$UV_VERSION" in \
        latest) UV_TAG=$(curl -s -I https://github.com/astral-sh/uv/releases/latest | grep location | cut -d"/" -f 8 | tr -d '[:space:]') ;; \
        *) UV_TAG="$UV_VERSION" ;; \
    esac; \
    echo "Installing uv=$UV_TAG" ;\
    curl --proto '=https' --tlsv1.2 -LsSf https://releases.astral.sh/github/uv/releases/download/$UV_TAG/uv-installer.sh | sh ;\
    strip --strip-unneeded /root/.local/bin/uv ;\
    strip --strip-unneeded /root/.local/bin/uvx ;\
    $HOME/.local/bin/uv python install $PYTHON_VERSION ;\
    find ${UV_PYTHON_INSTALL_DIR} -type f -executable -exec strip --strip-unneeded {} \;

# Build image by copying everything
FROM gcr.io/distroless/cc:nonroot

ARG PYTHON_VERSION=3.15

ENV LANG C.UTF-8

ENV PATH=/opt/python/cpython-$PYTHON_VERSION-linux-x86_64-gnu/bin/:/usr/local/bin/:$PATH \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_PREFERENCE=only-managed

WORKDIR /app

COPY --from=builder /opt/python /opt/python
COPY --from=builder /root/.local/bin/uv /usr/local/bin/uv
COPY --from=builder /root/.local/bin/uvx /usr/local/bin/uvx

CMD ["/usr/local/bin/uv", "help"]
