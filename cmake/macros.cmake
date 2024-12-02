macro ( make_static_library TARGET )
    set( options )
    set( multiValueArgs DEPS )

    cmake_parse_arguments ( CIMSL "${options}" "" "${multiValueArgs}" ${ARGN} )

    glob_headers_and_sources ( HEADERS SOURCES )

    add_library( ${TARGET} STATIC ${HEADERS} ${SOURCES} )

    if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories( ${TARGET} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" )
    endif ()

    if ( CIMSL_DEPS )
        target_link_libraries ( ${TARGET} PUBLIC ${CIMSL_DEPS} )
    endif ()

    enable_autoformatter ( ${TARGET} )
    apply_compile_options ( ${TARGET} )
endmacro()

macro ( make_executable TARGET )
    set( options )
    set( multiValueArgs DEPS )

    cmake_parse_arguments ( CIME "${options}" "" "${multiValueArgs}" ${ARGN} )

    glob_headers_and_sources ( HEADERS SOURCES )

    add_executable( ${TARGET} ${SOURCES} )

    if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories( ${TARGET} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" )
    endif ()

    if ( CIME_DEPS )
        target_link_libraries ( ${TARGET} PUBLIC ${CIME_DEPS} )
    endif ()

    enable_autoformatter ( ${TARGET} )
    apply_compile_options ( ${TARGET} )
endmacro()
