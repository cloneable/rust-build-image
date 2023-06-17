FROM debian:bookworm-slim AS builder

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
        curl \
        flatbuffers-compiler \
        gawk \
        git \
        gnupg \
        jq \
        libssl-dev \
        llvm-spirv-15 \
        make \
        pkg-config \
        protobuf-compiler \
        sed \
        spirv-tools \
        wabt \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN (curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup-installer.sh) \
    && chmod +x rustup-installer.sh \
    && ./rustup-installer.sh -y \
        --default-toolchain stable \
        --component cargo,clippy,rustfmt
ENV PATH=/root/.cargo/bin:${PATH}

RUN cargo install --locked \
        cargo-all-features \
        cargo-audit \
        cargo-deny \
        cargo-machete \
        cargo-nextest \
        cargo-update \
        sccache

RUN cargo install --locked \
        wasm-bindgen-cli \
        cargo-binutils \
        wasm-gc \
        wasm-snip
