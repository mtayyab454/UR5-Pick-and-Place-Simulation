cmake_minimum_required(VERSION 2.8.3)
project(ur_kinematics)

add_compile_options(-std=c++11)

find_package(catkin REQUIRED COMPONENTS roscpp geometry_msgs pluginlib tf_conversions)

find_package(Boost REQUIRED COMPONENTS system)

catkin_python_setup()

catkin_package(
  INCLUDE_DIRS include
  LIBRARIES ur3_kin ur5_kin ur10_kin 
  CATKIN_DEPENDS roscpp geometry_msgs 
    pluginlib tf_conversions
  DEPENDS Boost
)


###########
## Build ##
###########

include_directories(SYSTEM ${Boost_INCLUDE_DIR})
include_directories(include ${catkin_INCLUDE_DIRS})

add_library(ur3_kin src/ur_kin.cpp)
set_target_properties(ur3_kin PROPERTIES COMPILE_DEFINITIONS "UR3_PARAMS")

add_library(ur5_kin src/ur_kin.cpp)
set_target_properties(ur5_kin PROPERTIES COMPILE_DEFINITIONS "UR5_PARAMS")

add_library(ur10_kin src/ur_kin.cpp)
set_target_properties(ur10_kin PROPERTIES COMPILE_DEFINITIONS "UR10_PARAMS")


#############
## Install ##
#############

install(TARGETS ur3_kin ur5_kin ur10_kin
  ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

# install header files
install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)


