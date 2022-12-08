cmake_minimum_required(VERSION 2.8.3)
project(robots_description)

find_package(catkin REQUIRED)
catkin_package()
install(FILES  launch/turtlebot.launch
	           launch/multi-robot.launch
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
install(
		DIRECTORY model
		DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
		)
