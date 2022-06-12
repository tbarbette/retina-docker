# Docker image for Retina

This docker image provides an easy to use docker image to run the sample apps of [Retina](https://github.com/stanford-esrg/retina) or a new one that prints the tls handshakes (print_tls). It will use a PCAP socket to sniff packets from a physical interface. While it does compile DPDK, it is configured to avoid hugepages and other run-time dependencies so this docker provides an easy functional test.

**However you won't get the (very important!) hardware acceleration of Retina, the PCAP layer is very slow, RSS will not work so Retina is limited to a single core. In no way this Docker is meant for performance testing.**

## Installation 

### Install docker

See https://docs.docker.com/get-docker/

### Run the container

    docker run -it --rm --network host --name my_retina tbarbette/retina eth0 print_tls
    
eth0 being the name of your interface on which you want to TAP and print_tls the application to launch (from the examples folder in Retina, or this special one provided for demo)

### Modify the container

Clone this repository and for instance change the filter in print_tls/src/main.rs.

    #[filter("")]
    
Could become:

    #[filter("tls.sni ~ '(.+?\\.)?nflxvideo\\.net'")]
    
or change the Rust callbacks, ... Follow the Retina API at https://stanford-esrg.github.io/retina/retina_core/

then build the docker image with

    docker build -t retina .
    
and run your own image with :

    docker run -it --rm --network host --name my_retina retina eth0 tls_log

Notice we use retina instead of tbarbette/retina
