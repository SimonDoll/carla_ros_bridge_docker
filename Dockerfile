FROM nvidia/cudagl:10.2-devel-ubuntu18.04

# Adapted from https://github.com/atinfinity/carla_ros_bridge_docker
# Requires caral 0.9.9 compiled tar.gz and additional maps at build context .
# files should be called 0.9.9, minor version e.g. 0.9.9.4 is ignored
ARG CARLA_VERSION=0.9.9
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# add new sudo user
ENV USERNAME melodic
ENV HOME /home/$USERNAME
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        less \
        emacs \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        xsel \
        xdg-user-dirs \
        python-pip \
        python-protobuf \
        python-pexpect \
        pcl-tools \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ROS Melodic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-melodic-desktop-full \
        python-rosdep \
        python-rosinstall \
        python-rosinstall-generator \
        python-wstool \
        build-essential \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# addtional ROS package
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-melodic-derived-object-msgs \
        ros-melodic-ackermann-msgs \
        ros-melodic-ainstein-radar-msgs \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# get catkin tools
RUN apt-get update \
    && apt install wget \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
    && wget -q http://packages.ros.org/ros.key -O - | sudo apt-key add - \
    && apt-get update \
    && apt-get install -y python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*


RUN pip install \
        simple-pid \
        numpy \
        pygame \
        networkx

RUN rosdep init

USER $USERNAME
WORKDIR /home/$USERNAME
RUN rosdep update


COPY CARLA_${CARLA_VERSION}.tar.gz /home/$USERNAME/
RUN mkdir CARLA_${CARLA_VERSION} && \
    tar xfvz CARLA_${CARLA_VERSION}.tar.gz -C CARLA_${CARLA_VERSION} && \
    rm /home/$USERNAME/CARLA_${CARLA_VERSION}.tar.gz
COPY AdditionalMaps_${CARLA_VERSION}.tar.gz /home/$USERNAME/
RUN tar xfvz AdditionalMaps_${CARLA_VERSION}.tar.gz -C /home/$USERNAME/CARLA_${CARLA_VERSION}/ && \
    rm /home/$USERNAME/AdditionalMaps_${CARLA_VERSION}.tar.gz

RUN echo "export PYTHONPATH=$PYTHONPATH:~/CARLA_${CARLA_VERSION}/PythonAPI/carla/dist/carla-${CARLA_VERSION}-py2.7-linux-x86_64.egg:~/CARLA_${CARLA_VERSION}/PythonAPI/carla" >> ~/.bashrc


SHELL ["/bin/bash", "-c"]
RUN mkdir -p ~/workspace/src && \
    source /opt/ros/melodic/setup.bash && \
    cd ~/workspace && \
    catkin init && \
    cd src && \
    git clone --recursive https://github.com/carla-simulator/ros-bridge.git -b 0.9.8 && \
    cd ~/workspace && \
    catkin build -DCMAKE_BUILD_TYPE=Release && \
    source ~/workspace/devel/setup.bash

RUN cd /home/$USERNAME && \
    git clone https://github.com/carla-simulator/scenario_runner.git && \
    sed -i '/carla/d' scenario_runner/requirements.txt && \
    sudo pip install -r scenario_runner/requirements.txt

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    echo "source ~/workspace/devel/setup.bash" >> ~/.bashrc && \
    echo "export SCENARIO_RUNNER_PATH=/home/$USERNAME/scenario_runner" >> ~/.bashrc
