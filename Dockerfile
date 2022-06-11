FROM rust:1.61-bullseye

MAINTAINER tom.barbette@uclouvain.be

ADD VERSION .

RUN  \
    apt-get update &&\
    apt-get install -y build-essential meson pkg-config libnuma-dev python3-pyelftools libpcap-dev libclang-dev python3-pip git vim net-tools rdma-core libibverbs1 libibverbs-dev

RUN mkdir /dpdk

WORKDIR /dpdk

RUN   \
	wget http://fast.dpdk.org/rel/dpdk-21.08.tar.xz  &&\
    tar --strip-components=1 -xJf dpdk-21.08.tar.xz &&\
    ls /dpdk &&\
#    meson --prefix=/dpdk build &&\
    meson --prefix=/dpdk -D disable_drivers=net/mlx4 -D disable_drivers=net/mlx5 -Dcpu_instruction_set=generic build &&\
    cd build &&\
    ninja install &&\
    ldconfig


WORKDIR /

RUN \
    git clone http://github.com/stanford-esrg/retina.git && cd retina

COPY print_tls/ /retina/examples/print_tls/

WORKDIR /retina

RUN \
    export DPDK_PATH=/dpdk &&\
    export LD_LIBRARY_PATH=$DPDK_PATH/lib/x86_64-linux-gnu &&\
    export PKG_CONFIG_PATH=$LD_LIBRARY_PATH/pkgconfig &&\
    sed -i '/default = \["mlx5"\]/d' core/Cargo.toml &&\
    sed -i 's#"examples/basic",#"examples/basic","examples/print_tls",#' Cargo.toml &&\
    cargo build --release

WORKDIR /retina

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

