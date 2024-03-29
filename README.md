# Docker image for Retina

This docker image provides an easy-to-use docker image to run the sample apps of [Retina](https://github.com/stanford-esrg/retina) or a new one that prints the TLS handshakes (print_tls). It will use a PCAP socket to sniff packets from a physical interface. While it does compile DPDK, it is configured to avoid hugepages and other run-time dependencies so this docker provides an easy functional test.

**However, you won't get the (very important!) hardware acceleration of Retina. Indeed the PCAP layer is very slow, and RSS will not work. Therefore, Retina is limited to a single core. In no way is this Docker image meant for performance testing.** If you want to try the real thing, you may use the [CloudLab experiment](https://github.com/tbarbette/retina-expe/) instead.

A [video of a demo](https://uclouvain-my.sharepoint.com/:v:/g/personal/tom_barbette_uclouvain_be/EcxPP7TiPIpCndpuai6aVI4B8Ryz_FBDM3tYKiFVqSPMWQ?e=q9zQ7A) has been made as part of the SIGCOMM AEC evaluation. It showcases how to run the `log_tls` app, then the `print_tls` app, and finally how to modify and recompile the `print_tls` application to only filter Netflix packets.

## Installation 

### Install docker

See https://docs.docker.com/get-docker/

### Run the container

    docker run -it --rm --network host --name my_retina tbarbette/retina eth0 print_tls
    
`eth0` being the name of your interface on which you want to TAP and `print_tls` the application to launch (you may try other apps from [the examples folder in Retina](https://github.com/stanford-esrg/retina/tree/main/examples)).

#### Run a command inside the container

If you want to run a command, such as `wget https://www.google.com` inside the container while retina is running, you may do :

`docker exec -it my_retina wget https://www.google.com`

Note that by default, the docker app quits after 60 seconds. Therefore running the command after the docker terminated will fail.

### Modify the container

Clone this repository and, for instance, change the filter in `print_tls/src/main.rs`.

    #[filter("")]
    
Which can become:

    #[filter("tls.sni ~ '(.+?\\.)?nflxvideo\\.net'")]
    
or change the Rust callbacks or anything you want. Follow the Retina API at https://stanford-esrg.github.io/retina/retina_core/

then build the docker image with

    docker build -t retina .
    
and run your own image with :

    docker run -it --rm --network host --name my_retina retina eth0 tls_log

Notice we use `retina` instead of `tbarbette/retina` which is the local image you just built.

