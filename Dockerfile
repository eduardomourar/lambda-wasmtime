FROM amazonlinux:2.0.20191217.0

LABEL url="https://github.com/chiefbiiko/lambda-wasmtime" \
  version="0.3.3" \
  title="runtime-build-image" \
  description="Docker image for building the lambda-wasmtime runtime" \
  maintainer="Noah Anabiik Schwarz" \
  license="MIT"

ENV RUST_VERSION=1.41.0 \
  CARGO_MAKE_VERSION=0.27.0 \
  PATH=/root/.cargo/bin:$PATH \
  PKG_CONFIG_ALLOW_CROSS=true \
  CARGO_BUILD_TARGET=x86_64-unknown-linux-musl \
  CC_x86_64_unknown_linux_musl=clang \
  CXX_x86_64_unknown_linux_musl=clang++ \
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=clang++ \
  RUNTIME_ZIP_FILE_NAME=runtime.zip

RUN yum install -y clang clang-libs clang-devel cmake3 make ncurses-compat-libs ncurses-devel openssl-devel unzip zip && \
  ln -s /usr/bin/cmake3 /usr/bin/cmake && \
  rm -rf /var/cache/yum && \
  curl -fsSL https://sh.rustup.rs | sh -s -- --default-toolchain $RUST_VERSION -y && \
  rustup target add x86_64-unknown-linux-musl && \
  temp_file=$(mktemp) && temp_dir=$(mktemp -d) && \
  curl -fsSL https://github.com/sagiegurari/cargo-make/releases/download/$CARGO_MAKE_VERSION/cargo-make-v$CARGO_MAKE_VERSION-x86_64-unknown-linux-musl.zip -o $temp_file && \
  unzip $temp_file -d $temp_dir && \
  mv $temp_dir/cargo-make-v$CARGO_MAKE_VERSION-x86_64-unknown-linux-musl/cargo-make /root/.cargo/bin/cargo-make && \
  rm $temp_file && rm -rf $temp_dir

VOLUME /home

WORKDIR /home

COPY Cargo.toml Makefile.toml /home/

COPY src /home/src/

CMD ["cargo", "make", "runtime"]
