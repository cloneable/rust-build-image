#!/usr/bin/env bash
set -euo pipefail

RUSTUP_VERSION="1.26.0"
ARCH="$(dpkg --print-architecture)"

case "${ARCH##*-}" in
    amd64) RUST_TARGET='x86_64-unknown-linux-gnu'; RUSTUP_SHA256='0b2f6c8f85a3d02fde2efc0ced4657869d73fccfce59defb4e8d29233116e6db' ;;
    arm64) RUST_TARGET='aarch64-unknown-linux-gnu'; RUSTUP_SHA256='673e336c81c65e6b16dcdede33f4cc9ed0f08bde1dbe7a935f113605292dc800' ;;
    *) echo >&2 "unsupported architecture: ${ARCH}"; exit 1 ;;
esac

wget "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${RUST_TARGET}/rustup-init"
echo "${RUSTUP_SHA256} *rustup-init" | sha256sum -c -

chmod +x rustup-init
./rustup-init -y \
    --no-modify-path \
    --profile minimal \
    --default-toolchain "${RUST_VERSION}" \
    --default-host "${RUST_TARGET}" \
    --component cargo,clippy,rustfmt

rm rustup-init
chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}"

rustup --version
cargo --version
rustc --version
