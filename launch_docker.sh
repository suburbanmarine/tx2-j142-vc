docker run -it                           \
	nvidia_tx2_j142_vc                   \
	--rm                                 \
	--network=host                       \
	--privileged                         \
	--volume=”/dev/bus/usb:/dev/bus/usb” \
	--user="$(id -u):$(id -g)" \
	/bin/bash

#	--volume=”/proc/sys/fs/binfmt_misc:/proc/sys/fs/binfmt_misc” \