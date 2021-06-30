# SPOT watchdog demo

# setup demo environment

For more details, please see [jsk_spotkinova_robot](https://github.com/708yamaguchi/jsk_robot/tree/spot-kinova/jsk_spotkinova_robot).
```bash
$ mkdir -p ~/spotkinova_ws/src
$ cd ~/spotkinova_ws/src
$ wstool init 
$ wstool merge -t . https://raw.githubusercontent.com/tkmtnt7000/jsk_demos/tsukamoto/spot-kinova-watch-dog/jsk_spot_watch_dog/jsk_spot_watch_dog.rosinstall
$ wstool merge -t . https://raw.githubusercontent.com/708yamaguchi/jsk_robot/spot-kinova/jsk_spotkinova_robot/jsk_spotkinova.rosinstall
$ wstool update
$ rosdep update
$ rosdep install -y -r --from-paths . --ignore-src
$ cd ~/spotkinova_ws
$ source /opt/ros/$ROS_DISTRO/setup.bash
$ catkin init
$ catkin build jsk_spot_watch_dog
```

## usage

### base process:
We need to setup python3 based catkin-workspace for object detection, so please see [setup a catkin workspace for coral usb](https://github.com/sktometometo/jsk_robot/tree/develop/spot/jsk_spot_robot#setup-a-catkin-workspace-for-coral-usb) and setup it.

```bash
$ roslaunch jsk_spotkinova_startup spot_kinova_bringup.launch # please follow https://github.com/708yamaguchi/jsk_robot
$ roslaunch jsk_spot_startup object_detection_and_tracking.launch # need to source a python3 based catkin-workspace (please check roslaunch jsk_spot_startup object_detection_and_tracking.launch)
```
### demo process

#### option1: ros smach based on python:

```bash
$ roslaunch jsk_spot_watch_dog watch_dog_smach.launch
```

#### option2: ros smach based on roseus:

```bash
$ roslaunch jsk_spot_watch_dog watch_dog_roseus_smach.launch
```

