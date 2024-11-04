cmake_minimum_required ( VERSION 3.26 )

include ( "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/get_cpp_init.cmake" )

bootstrap_cpm ()

project ( TEST )

enable_testing()

add_subdirectory( "${CMAKE_CURRENT_SOURCE_DIR}/lib" )
add_subdirectory( "${CMAKE_CURRENT_SOURCE_DIR}/bin" )
