FROM debian:bookworm-slim AS builder
LABEL org.opencontainers.image.source=https://github.com/cloneable/rust-build-image

WORKDIR /root

COPY ca-certificates_all.deb .
RUN dpkg --force-depends --install ca-certificates_all.deb || true
RUN update-ca-certificates

RUN sed -i -re 's,http://deb.debian.org/,https://ftp-stud.hs-esslingen.de/,' /etc/apt/sources.list.d/debian.sources

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get --fix-broken install -y \
    && apt-get dist-upgrade --no-install-recommends -y

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
        zsh \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup dev \
    && adduser \
        --ingroup dev \
        --shell /bin/bash \
        --comment "" \
        --disabled-password \
        dev \
    && chown -R dev:dev /home/dev

USER dev:dev
WORKDIR /home/dev

ENV RUSTUP_HOME=/home/dev/.rustup \
    CARGO_HOME=/home/dev/.cargo \
    PATH="/home/dev/.cargo/bin:${PATH}" \
    RUST_VERSION=1.84.0
COPY install-rust.sh .
RUN ./install-rust.sh && rm -f ./install-rust.sh

RUN cargo install --locked sccache \
        --no-default-features \
    && mkdir -p /home/dev/.cache/sccache \
    && cat >"${CARGO_HOME}/config.toml" <<EOF
[build]
rustc-wrapper = "${CARGO_HOME}/bin/sccache"
incremental = false
EOF

RUN cargo install --locked \
        cargo-update \
        cargo-all-features \
        cargo-audit \
        cargo-binutils \
        cargo-deny \
        cargo-machete \
        cargo-nextest \
        wasm-gc \
        wasm-snip \
        difftastic \
        git-delta \
        ripgrep \
    && sccache --show-stats
