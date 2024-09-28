# Download and include CPM
# Optionally specify a version to download (defaults to latest)
function ( bootstrap_cpm )
    set ( oneValueArgs VERSION )

    cmake_parse_arguments( BOOTSTRAP_CPM "" "${oneValueArgs}" "" ${ARGN} )

    set ( VERSION "latest" )
    if ( BOOTSTRAP_CPM_VERSION )
        set ( VERSION "${BOOTSTRAP_CPM_VERSION}" )
    endif()

    file ( DOWNLOAD 
        "https://github.com/cpm-cmake/CPM.cmake/releases/${VERSION}/download/get_cpm.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/get_cpm.cmake"
    )

    include ( "${CMAKE_CURRENT_BINARY_DIR}/get_cpm.cmake" )
endfunction ()

# For the current source directory
# glob all .hpp files in the include subfolder into variable with name specified in HEADERS_OUTVARNAME
# glob all .cpp files in the src subfolder into variable with name specified in SOURCES_OUTVARNAME}
function ( glob_headers_and_sources HEADERS_OUTVARNAME SOURCES_OUTVARNAME )
    file ( GLOB_RECURSE
        LOCAL_HEADERS
        "${CMAKE_CURRENT_SOURCE_DIR}/include**/*.hpp"
    )
	
	file ( GLOB_RECURSE
		LOCAL_HEADERS2
        "${CMAKE_CURRENT_SOURCE_DIR}/include**/*.h"
	)

    file ( GLOB_RECURSE
        LOCAL_SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src**/*.cpp"
    )

    source_group(
        TREE "${CMAKE_CURRENT_SOURCE_DIR}"
        FILES ${LOCAL_HEADERS} ${LOCAL_HEADERS2}
    )

    source_group(
        TREE "${CMAKE_CURRENT_SOURCE_DIR}"
        FILES ${LOCAL_SOURCES}
    )

    set ( ${HEADERS_OUTVARNAME} "${LOCAL_HEADERS} ${LOCAL_HEADERS2}" PARENT_SCOPE )
    set ( ${SOURCES_OUTVARNAME} "${LOCAL_SOURCES}" PARENT_SCOPE )
endfunction ()

# Examines current git tag
# Stores inferred version into variable with name specified in OUTVAR_PROJECT_VERSION
# - this one can be used in project ( VERSION ) parameter
# The full version (including commit hash) is stored in variable with name specified
# in OUTVAR_FULL_VERSION
function ( get_git_version )
    set ( oneValueArgs PROJECT_VERSION_VARIABLE FULL_VERSION_VARIABLE )

    cmake_parse_arguments( GET_VERSION_FROM_GIT "" "${oneValueArgs}" "" ${ARGN} )

    find_package( Git REQUIRED )

    execute_process (
        COMMAND ${GIT_EXECUTABLE} describe --tags
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE LOCAL_STDOUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    string ( REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" LOCAL_CORE_VERSION "${LOCAL_STDOUT}" )

    message ( "Found full git version: ${LOCAL_STDOUT}" )
    message ( "Inferred project version: ${LOCAL_CORE_VERSION}" )

    if ( GET_VERSION_FROM_GIT_PROJECT_VERSION_VARIABLE )
        set ( ${GET_VERSION_FROM_GIT_PROJECT_VERSION_VARIABLE} "${LOCAL_CORE_VERSION}" PARENT_SCOPE )
    endif ()

    if ( GET_VERSION_FROM_GIT_FULL_VERSION_VARIABLE )
        set ( ${GET_VERSION_FROM_GIT_FULL_VERSION_VARIABLE} "${LOCAL_STDOUT}" PARENT_SCOPE )
    endif ()
endfunction ()

include ( FetchContent )

# Use FetchContent to download a dependency from a URL
# If IS_HEADERONLY is TRUE then the file will just be downloaded
# otherwise the file will be extracted
# You can test ${DEPNAME}_POPULATED to see if download was successful
# The dependency is downloaded (and possibly extracted) into
# ${DEPNAME}_FOLDER
function ( fetch_prebuilt_dependency DEPNAME URL IS_HEADERONLY )
    if ( ${IS_HEADERONLY} )
        FetchContent_Declare ( ${DEPNAME}
            URL ${URL}
            DOWNLOAD_NO_PROGRESS TRUE
            DOWNLOAD_NO_EXTRACT TRUE
        )
    else ()
        FetchContent_Declare ( ${DEPNAME}
            URL ${URL}
            DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        )
    endif ()

    FetchContent_MakeAvailable ( ${DEPNAME} )

    string ( TOLOWER ${DEPNAME} DEPNAME_LOWER )
    set ( "${DEPNAME}_FOLDER" "${${DEPNAME_LOWER}_SOURCE_DIR}" PARENT_SCOPE )
endfunction ()
