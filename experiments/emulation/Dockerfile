FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-user qemu-system-misc python3 ca-certificates make file xz-utils \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
