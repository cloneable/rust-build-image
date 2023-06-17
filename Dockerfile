# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS builder
LABEL org.opencontainers.image.source=https://github.com/cloneable/rust-build-image

WORKDIR /root

RUN apt-get update && apt-get dist-upgrade --no-install-recommends -y

RUN apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        bazel-bootstrap \
        binaryen \
        clang-format \
        cmake \
        coreutils \
        curl \
        flatbuffers-compiler \
        gawk \
        git \
        gnupg \
        jq \
        libssl-dev \
        llvm-spirv-15 \
        make \
        mold \
        musl-dev \
        musl-tools \
        pkg-config \
        protobuf-compiler \
        sed \
        spirv-tools \
        wabt \
        wget \
    && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/usr/local/cargo/bin:${PATH}" \
    RUST_VERSION=stable
COPY install-rust.sh .
RUN ./install-rust.sh && rm -f ./install-rust.sh

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo install --locked sccache \
        --no-default-features \
    && mkdir -p /root/.cache/sccache \
    && cat >"${CARGO_HOME}/config.toml" <<EOF
[registries.crates-io]
protocol = "sparse"

[build]
rustc-wrapper = "${CARGO_HOME}/bin/sccache"
incremental = false
EOF

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/root/.cache/sccache \
    cargo install --locked \
        cargo-all-features \
        cargo-audit \
        cargo-deny \
        cargo-machete \
        cargo-nextest \
        cargo-update

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/root/.cache/sccache \
    cargo install --locked \
        wasm-bindgen-cli \
        cargo-binutils \
        wasm-gc \
        wasm-snip

RUN --mount=type=cache,target=/root/.cache/sccache \
    sccache --show-stats
