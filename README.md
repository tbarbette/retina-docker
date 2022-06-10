# Docker image for Retina

This docker image provides an easy to use docker image to run one of the sample apps of Retina, using a PCAP socket to sniff packets from a physical interface. While it does compile DPDK, it is configured to avoid hugepages and other run-time dependencies so this docker provides a functional test. However you won't get the (very important!) hardware acceleration of Retina.

## Installation 

### Install docker

See https://docs.docker.com/get-docker/

### Run the container

    docker run -it --rm --network host --name my_retina tbarbette/retina eth0 tls_log
    
    eth0 being the name of your interface on which you want to TAP and tls_log the application to launch (from the examples folder in Retina)

### Modify the container

Clone this repository and for instance change the filter in tls_log/src/main.rs.

    #[filter("")]
    
Should become:

    #[filter("tls.sni ~ '(.+?\\.)?nflxvideo\\.net'")] 

then build the docker image with

    docker build -t retina .
    
and run your own image with :

    docker run -it --rm --network host --name my_retina retina eth0 tls_log

Notice we use retina instead of tbarbette/retina
