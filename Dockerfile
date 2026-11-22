# Download uv/python
ARG DEBIAN_VERSION=trixie
FROM dhi.io/debian-base:$DEBIAN_VERSION-dev as builder

ARG UV_VERSION=0.13.9
ARG PYTHON_VERSION=3.15.2

ENV PATH=/opt/python:/usr/local/bin/:$PATH \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_PREFERENCE=only-managed

COPY --from=ghcr.io/astral-sh/uv:$UV_VERSION /uv /uvx /usr/local/bin

RUN set -e ;\
    apt update ;\
    apt install -y binutils ;\
    uv python install $PYTHON_VERSION ;\
    strip --strip-unneeded /usr/local/bin/uv ;\
    strip --strip-unneeded /usr/local/bin/uvx ;\
    find ${UV_PYTHON_INSTALL_DIR} -type f -executable -exec strip --strip-unneeded {} \;

# Build image by copying everything
ARG DEBIAN_VERSION=trixie
FROM dhi.io/debian-base:$DEBIAN_VERSION

ENV LANG C.UTF-8

ENV PATH=/opt/python:/usr/local/bin/$PATH \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_PREFERENCE=only-managed

WORKDIR /app

COPY --from=builder /opt/python /opt/python
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /usr/local/bin/uvx /usr/local/bin/uvx

ENTRYPOINT ["/usr/local/bin/uv"]
