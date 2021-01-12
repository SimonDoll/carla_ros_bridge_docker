# this is an easy yet unsecure way to allow the container to access the xserver
xhost +local:melodic

docker run \
-e SDL_VIDEODRIVER=x11 \
-e DISPLAY=$DISPLAY \
--env=TERM=xterm-256color \
--env=QT_X11_NO_MITSHM=1 \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-p 2000-2002:2000-2002 \
-it \
--gpus all \
--rm \
ros_carla:0.9.9 bash
