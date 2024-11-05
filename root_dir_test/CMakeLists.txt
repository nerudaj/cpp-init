cmake_minimum_required ( VERSION 3.26 )

set ( CPP_INIT_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake" )
include ( "cmake/get_cpp_init.cmake" )

project ( demo )

make_executable ( demo )
