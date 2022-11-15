On host system
1. build_docker.sh  - build a tx2 cross tool enviroment
2. launch_docker.sh - start the container in privileged mode. 

Inside docker
3. finish_image.sh - set up the image, installs packages into chroot
4. flash_image.sh to flash a connected TX2 that is in bootloader mode.

The lines referencing Acquire::http::Proxy Acquire::https::Proxy in Dockerfile and finish_image.sh set up a local caching proxy server that can be used to speed up rebuilds. It is highly recomended to use a caching proxy to reduce amount of time repetitivly fetching packages. I use apt-cacher-ng, a normal http cache like squid may work as well.