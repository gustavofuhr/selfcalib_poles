project( poles_extractor )
set(CMAKE_CXX_COMPILER g++)
cmake_minimum_required(VERSION 2.8)  

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package( OpenCV REQUIRED )
file(GLOB all_poles_extractor_src
	"include/*.h"
	"src/*.cpp"
)
file(GLOB all_poles_extractor_include
	"include/*.h"
)

add_executable( poles_extractor-bin ${all_poles_extractor_src} )
SET_TARGET_PROPERTIES(poles_extractor-bin
  PROPERTIES OUTPUT_NAME poles_extractor)

include_directories("include/" "../detector/include/" "../background/include/" "../background/third_party/subsense/")
# find the library backgorund
find_library(DETECTOR_LIB NAMES pedestrian_detector libpedestrian_detector
             HINTS ../detector/lib/ )
find_library(BACKGROUND_LIB NAMES background_segmentation libbackground_segmentation
             HINTS ../background/lib/ )


link_directories("${CMAKE_BINARY_DIR}/../detector/lib/")
target_link_libraries(poles_extractor-bin
	${OpenCV_LIBS}
	${DETECTOR_LIB}
    ${BACKGROUND_LIB})

add_library( poles_extractor SHARED
	src/poles_extractor.cpp
    src/poles_extractor_config.cpp
    src/interface_utils.cpp
    src/pole.cpp
	${all_poles_extractor_include}
)
target_link_libraries(poles_extractor
	${OpenCV_LIBS}
    ${DETECTOR_LIB}
	${BACKGROUND_LIB})


set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse -msse2 -msse3 -std=c++11 -std=c++1y")