#!/usr/bin/env bash
set -euo pipefail

RUSTUP_VERSION="1.27.1"
ARCH="$(dpkg --print-architecture)"

case "${ARCH##*-}" in
    amd64) RUST_TARGET='x86_64-unknown-linux-gnu'; RUSTUP_SHA256='6aeece6993e902708983b209d04c0d1dbb14ebb405ddb87def578d41f920f56d' ;;
    arm64) RUST_TARGET='aarch64-unknown-linux-gnu'; RUSTUP_SHA256='1cffbf51e63e634c746f741de50649bbbcbd9dbe1de363c9ecef64e278dba2b2' ;;
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

rustup --version
cargo --version
rustc --version
