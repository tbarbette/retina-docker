FROM rust

MAINTAINER tom.barbette@uclouvain.be

ADD VERSION .

RUN  \
    apt-get update &&\
    apt-get install -y build-essential meson pkg-config libnuma-dev python3-pyelftools libpcap-dev libclang-dev python3-pip git

RUN mkdir /dpdkk

WORKDIR /dpdk

RUN   \
	wget http://fast.dpdk.org/rel/dpdk-21.08.tar.xz  &&\
    tar --strip-components=1 -xJf dpdk-21.08.tar.xz &&\
    ls /dpdk &&\
    meson --prefix=/dpdk -D disable_drivers=net/mlx4 -D disable_drivers=net/mlx5 build &&\
    cd build &&\
    ninja install &&\
    ldconfig


WORKDIR /

RUN \
    git clone http://github.com/stanford-esrg/retina.git

COPY tls_log/ /retina/examples/tls_log/
COPY video/ /retina/examples/video/

WORKDIR /retina

RUN \
    export DPDK_PATH=/dpdk &&\
    export LD_LIBRARY_PATH=$DPDK_PATH/lib/x86_64-linux-gnu &&\
    export PKG_CONFIG_PATH=$LD_LIBRARY_PATH/pkgconfig &&\
    sed -i '/default = \["mlx5"\]/d' core/Cargo.toml &&\
    sed -i 's#"examples/basic",#"examples/basic","examples/tls_log","examples/video",#' Cargo.toml &&\
    cargo build --release

WORKDIR /retina

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

