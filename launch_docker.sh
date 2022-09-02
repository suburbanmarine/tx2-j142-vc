docker run                               \
	--rm                                 \
	--network=host                       \
	--privileged                         \
	--volume="/dev/bus/usb:/dev/bus/usb" \
	-it nvidia_tx2_j142_vc /bin/bash
	

	# --user="$(id -u):$(id -g)" \
	# --volume=”/proc/sys/fs/binfmt_misc:/proc/sys/fs/binfmt_misc” \