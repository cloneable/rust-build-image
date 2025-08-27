#!/usr/bin/env bash
set -euo pipefail

RUSTUP_VERSION="1.28.2"
ARCH="$(dpkg --print-architecture)"

case "${ARCH##*-}" in
    amd64) RUST_TARGET='x86_64-unknown-linux-gnu'; RUSTUP_SHA256='20a06e644b0d9bd2fbdbfd52d42540bdde820ea7df86e92e533c073da0cdd43c' ;;
    arm64) RUST_TARGET='aarch64-unknown-linux-gnu'; RUSTUP_SHA256='e3853c5a252fca15252d07cb23a1bdd9377a8c6f3efa01531109281ae47f841c' ;;
    *) echo >&2 "unsupported architecture: ${ARCH}"; exit 1 ;;
esac

wget "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_TARGET}/rustup-init"
echo "${RUSTUP_SHA256} *rustup-init" | sha256sum --check

chmod +x rustup-init
./rustup-init -y \
    --no-modify-path \
    --profile minimal \
    --default-toolchain "${RUST_VERSION}" \
    --default-host "${RUST_TARGET}" \
    --component cargo,clippy,rustfmt

rm rustup-init

rustup --version
cargo --version
rustc --version
