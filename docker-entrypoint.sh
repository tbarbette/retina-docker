#!/bin/bash
export DPDK_PATH=/dpdk
export LD_LIBRARY_PATH=$DPDK_PATH/lib/x86_64-linux-gnu
export PKG_CONFIG_PATH=$LD_LIBRARY_PATH/pkgconfig

if [ $# != 2 ] ; then
        echo "Usage: docker run [...] INTERFACE APP"
        exit 1
else
        echo "Interface : $1"
        echo "Application : $2"
fi

sed -i "s#iface=[a-zA-Z0-9]\+#iface=$1#" /retina/configs/online-vdev.toml

env LD_LIBRARY_PATH=$LD_LIBRARY_PATH RUST_LOG=info ./target/release/$2 -c /retina/configs/online-vdev.toml
