FROM alpine:latest AS staging

WORKDIR /root

ENV DEBFILE=ca-certificates_20250419_all.deb
ENV SHA256SUM=ef590f89563aa4b46c8260d49d1cea0fc1b181d19e8df3782694706adf05c184

RUN wget -O ca-certificates_all.deb "https://ftp-stud.hs-esslingen.de/debian/pool/main/c/ca-certificates/${DEBFILE}"
RUN echo "${SHA256SUM} *ca-certificates_all.deb" | sha256sum -c

FROM debian:bookworm-slim AS builder
LABEL org.opencontainers.image.source=https://github.com/cloneable/rust-build-image

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

COPY --from=staging /root/ca-certificates_all.deb .
RUN dpkg --force-depends --install ca-certificates_all.deb || true
RUN update-ca-certificates

RUN sed -i -re 's,http://deb.debian.org/,https://ftp-stud.hs-esslingen.de/,' /etc/apt/sources.list.d/debian.sources

RUN apt-get update \
    && apt-get --fix-broken install -y \
    && apt-get dist-upgrade --no-install-recommends -y

RUN apt-get install --no-install-recommends -y \
        aggregate \
        autoconf \
        automake \
        bazel-bootstrap \
        binaryen \
        build-essential \
        clang-format \
        cmake \
        coreutils \
        curl \
        dnsutils \
        flatbuffers-compiler \
        fzf \
        gawk \
        git \
        gh \
        gnupg2 \
        iproute2 \
        ipset \
        iptables \
        jq \
        less \
        libssl-dev \
        llvm-spirv-15 \
        locales \
        make \
        man-db \
        mold \
        musl-dev \
        musl-tools \
        nano \
        npm \
        pkg-config \
        procps \
        protobuf-compiler \
        sed \
        software-properties-common \
        sudo \
        spirv-tools \
        vim \
        wabt \
        wget \
        unzip \
        zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup --gid $USER_GID $USERNAME \
    && adduser \
        --uid $USER_UID --gid $USER_GID \
        --shell /bin/zsh \
        --comment "" \
        --disabled-password \
        $USERNAME \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

ENV HOME="/home/$USERNAME"
WORKDIR /home/$USERNAME

USER $USERNAME:$USERNAME

ENV RUSTUP_HOME="$HOME/.rustup" \
    CARGO_HOME="$HOME/.cargo" \
    PATH="$HOME/.cargo/bin:${PATH}" \
    RUST_VERSION="1.89.0"
COPY install-rust.sh .
RUN ./install-rust.sh && rm -f ./install-rust.sh

RUN cargo install sccache \
        --no-default-features \
    && mkdir -p /home/dev/.cache/sccache \
    && cat >"${CARGO_HOME}/config.toml" <<EOF
[build]
rustc-wrapper = "${CARGO_HOME}/bin/sccache"
incremental = false
EOF

RUN cp /etc/zsh/newuser.zshrc.recommended .zshrc
WORKDIR /workspace
