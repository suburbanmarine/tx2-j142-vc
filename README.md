1. build_docker.sh
2. launch_docker.sh - start the container in privileged mode. 

3. finish_image.sh - set up the image
4. flash_image.sh to flash a connected TX2 that is in bootloader mode.

The lines referencing Acquire::http::Proxy Acquire::https::Proxy set up a local caching proxy server that can be used to speed up rebuilds. It is highly recomended to use a caching proxy to reduce amount of time repetitivly fetching packages.