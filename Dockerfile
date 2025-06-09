# Use Ubuntu 20.04 (required for ROS Noetic)
FROM ubuntu:20.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set up a non-root user for development
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install basic tools and ROS Noetic Desktop-Full (includes Gazebo)
RUN apt-get update && \
    apt-get install -y curl gnupg2 lsb-release sudo && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y ros-noetic-desktop-full python3-catkin-tools python3-pip python3-rosdep python3-colcon-common-extensions git && \
    apt-get install -y python3-opencv python3-numpy python3-yaml python3-scipy python3-matplotlib && \
    apt-get install -y libopencv-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y x11-apps && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Create user and set up home
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

# Set up ROS environment
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Update rosdep for user
RUN rosdep update

# Set up catkin workspace if not present
RUN mkdir -p ~/UR5-Pick-and-Place-Simulation/catkin_ws/src

# Fix Python setuptools compatibility issue for ROS Noetic
RUN pip3 install --upgrade pip && \
    pip3 install setuptools==58.2.0 && \
    pip3 install importlib-metadata==4.13.0 && \
    pip3 install pyquaternion

# Clone and set up YOLOv5
RUN cd ~ && \
    git clone https://github.com/ultralytics/yolov5 && \
    cd yolov5 && \
    pip3 install -r requirements.txt

# Set entrypoint to bash with ROS sourced
ENTRYPOINT ["bash", "-c", "source /opt/ros/noetic/setup.bash && exec bash"]

# Instructions for the user (not executed)
# To build your workspace:
# cd ~/UR5-Pick-and-Place-Simulation/catkin_ws
# catkin build
# To run Gazebo with GUI, ensure X11 forwarding is set up (see README)
