# carla_ros_bridge_docker

## Introduction
This is a Dockerfile to use [CARLA ROS bridge](https://github.com/carla-simulator/ros-bridge) on Docker container.

## Requirements
* NVIDIA graphics driver
* Docker
* nvidia-docker2

## Preparation
### Download CARLA Simulator
Please download the CARLA Simulator and addtional map file from <https://github.com/carla-simulator/carla/releases/tag/0.9.9>.  
Rename the file to the major version e.g 0.9.9 (minor patched version e.g. 0.9.9.4 is ignored).
And, please put CARLA Simulator in the same directory as the Dockerfile.  
This time, I used the following package.

- `CARLA_0.9.8.tar.gz`
- `AdditionalMaps_0.9.8.tar.gz`

### Build Docker image
```shell
$ docker build -t carla:0.9.8 -f Dockerfile.melodic .
```

### Create Docker container
```shell
$ ./launch_container.sh
```

## Usage
### CARLA ROS bridge
#### Launch CARLA Simulator
Please launch CARLA Simulator by the following command.

```shell
$ cd CARLA_0.9.8
$ ./CarlaUE4.sh -windowed -ResX=160 -ResY=120
```

#### Set the configuration of CARLA Simulator
```shell
$ cd CARLA_0.9.8/PythonAPI
$ python util/config.py -m Town03 --fps 10
```

#### Launch CARLA ROS bridge
```shell
$ roslaunch carla_ros_bridge carla_ros_bridge_with_example_ego_vehicle.launch vehicle_filter:='vehicle.toyota.prius*'
```

### CARLA AD Demo
#### Launch CARLA Simulator
Please launch CARLA Simulator by the following command.

```shell
$ cd CARLA_0.9.8
$ ./CarlaUE4.sh -windowed -ResX=160 -ResY=120
```

#### Set the configuration of CARLA Simulator
```shell
$ cd CARLA_0.9.8/PythonAPI
$ python util/config.py -m Town01 --fps 10
```

#### Launch CARLA AD Demo
```shell
$ roslaunch carla_ad_demo carla_ad_demo_with_rviz.launch vehicle_filter:='vehicle.toyota.prius*'
```
