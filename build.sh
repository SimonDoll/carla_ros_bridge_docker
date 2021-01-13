#!/bin/bash
carla_repo="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux"
carla_release="CARLA_0.9.9.4.tar.gz"
carla_map_release="AdditionalMaps_0.9.9.4.tar.gz"
carla_release_major="CARLA_0.9.9.tar.gz"
carla_map_release_major="AdditionalMaps_0.9.9.tar.gz"

if [ -f "$carla_release" ] && [ -f "$carla_release_major" ]; then
	echo "[DEPENDENCY]: Downloading CARLA release."
	wget "$carla_repo/$carla_release"
        mv $carla_map_release $carla_release_major
else
	echo "[DEPENDENCY]: CARLA release already available."
fi

if [ -f "$carla_map_release" ] && [ -f "$carla_map_release_major" ]; then
	echo "[DEPENDENCY]: CARLA map release already available."
	wget "$carla_repo/$carla_map_release"
        mv $carla_map_release $carla_map_release_major
else
        echo "[DEPENDENCY]: CARLA map release already available."
fi

check_docker_image=$(docker image list | grep carla | grep "0.9.9")
if [ "$check_docker_image" == "" ]; then
	echo "[DOCKER]:     Build image."
	docker build -t carla:0.9.9 -f Dockerfile .
else 
	echo "[DOCKER]:     Image already found on system."
fi
