cmake_minimum_required(VERSION 3.0)
project(rapidjson)

set(CMAKE_BUILD_TYPE "Debug")
# # SET(CMAKE_BUILD_TYPE "Release")
aux_source_directory(. SOURCE_DIRS)


find_package(GTest REQUIRED)
find_package(Threads REQUIRED)
include_directories(${GTest_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/third_party/rapidjson)
include_directories(.)

add_executable(main main.cpp ${SOURCE_DIRS})
target_link_libraries(main  ${GTEST_BOTH_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

enable_testing()
add_test(Test main)

