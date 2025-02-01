# Function: bootstrap_cpm
# Description: Bootstraps the CPM package manager by downloading and including the specified version of the CPM.cmake script.
# Arguments:
#   VERSION - The version of CPM to download. Defaults to "latest".
# Example:
#   bootstrap_cpm()
#   bootstrap_cpm(VERSION "v0.34.0")
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

# Function: glob_headers_and_sources
# Description: Recursively globs header and source files, organizes them into source groups, and sets the output variables with the discovered files.
# Arguments:
#   HEADERS_OUTVARNAME - Variable to store the list of discovered header files.
#   SOURCES_OUTVARNAME - Variable to store the list of discovered source files.
# Example:
#   glob_headers_and_sources(my_headers my_sources)
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
    
    file ( GLOB_RECURSE
        LOCAL_SOURCES2
        "${CMAKE_CURRENT_SOURCE_DIR}/source**/*.cpp"
    )

    source_group(
        TREE "${CMAKE_CURRENT_SOURCE_DIR}"
        FILES ${LOCAL_HEADERS} ${LOCAL_HEADERS2}
    )

    source_group(
        TREE "${CMAKE_CURRENT_SOURCE_DIR}"
        FILES ${LOCAL_SOURCES} ${LOCAL_SOURCES2}
    )

    set ( ${HEADERS_OUTVARNAME} "${LOCAL_HEADERS};${LOCAL_HEADERS2}" PARENT_SCOPE )
    set ( ${SOURCES_OUTVARNAME} "${LOCAL_SOURCES}" PARENT_SCOPE )
    set ( ${SOURCES_OUTVARNAME} "${LOCAL_SOURCES};${LOCAL_SOURCES2}" PARENT_SCOPE )
endfunction ()

# Function: get_git_version
# Description: Retrieves the current git version using `git describe --tags` and sets the specified project version variables.
# Arguments:
#   PROJECT_VERSION_VARIABLE - Variable to store the inferred project version.
#   FULL_VERSION_VARIABLE    - Variable to store the full git version.
# Additional Information:
#   The version string is retrieved using the `git describe --tags` command, which extracts the latest annotated tag from the git history.
#   The tags should follow the Semantic Versioning (semver) format, with an optional 'v' prefix. For example, 'v1.0.0' or '1.0.0'.
# Example:
#   get_git_version(PROJECT_VERSION_VARIABLE my_project_version FULL_VERSION_VARIABLE my_full_version)
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

function ( __fetch_common DEPNAME )
    FetchContent_MakeAvailable ( ${DEPNAME} )

    string ( TOLOWER ${DEPNAME} DEPNAME_LOWER )
    set ( "${DEPNAME}_FOLDER" "${${DEPNAME_LOWER}_SOURCE_DIR}" )
    
    return ( PROPAGATE "${DEPNAME}_FOLDER" )
endfunction ()

# Function: fetch_prebuilt_dependency
# Description: Fetches a prebuilt dependency from a specified URL.
# Arguments:
#   DEPNAME    - Name of the dependency.
# Options:
#   URL        - The URL from which to fetch the dependency. This parameter is mandatory.
#   CACHE_DIR  - The directory where the dependency will be cached. Defaults to "${PROJECT_BINARY_DIR}/_deps" if not specified.
# Example:
#   fetch_prebuilt_dependency(MyDependency URL "http://example.com/mydependency.zip")
#   fetch_prebuilt_dependency(MyDependency URL "http://example.com/mydependency.zip" CACHE_DIR "/path/to/cache")
function ( fetch_prebuilt_dependency DEPNAME )
    set ( oneValueArgs URL CACHE_DIR )
    
    cmake_parse_arguments( FHD "" "${oneValueArgs}" "" ${ARGN} )

    if ( NOT FHD_URL )
        message ( FATAL_ERROR "URL must be specified!" )
    endif ()
    
    set ( CACHE_DIR "${PROJECT_BINARY_DIR}/_deps" )
    if ( FHD_CACHE_DIR )
        set ( CACHE_DIR "${FHD_CACHE_DIR}" )
        message ( "Setting cache dir to: ${CACHE_DIR}" )
    endif()

    FetchContent_Declare ( ${DEPNAME}
        URL "${FHD_URL}"
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        PREFIX "${CACHE_DIR}"
    )

    __fetch_common ( ${DEPNAME} )
    return ( PROPAGATE "${DEPNAME}_FOLDER" )
endfunction ()

# Function: fetch_headeronly_dependency
# Description: This function fetches a header-only dependency from a specified URL.
# Parameters:
#   DEPNAME    - Name of the dependency.
# Options:
#   URL        - The URL from which to fetch the dependency. This parameter is mandatory.
#   CACHE_DIR  - The directory where the dependency will be cached. If not specified, defaults to "${PROJECT_BINARY_DIR}/_deps".
# Example:
#   fetch_headeronly_dependency(MyDependency URL "http://example.com/mydependency.zip")
function ( fetch_headeronly_dependency DEPNAME )
    set ( oneValueArgs URL CACHE_DIR )
    
    cmake_parse_arguments( FHD "" "${oneValueArgs}" "" ${ARGN} )

    if ( NOT FHD_URL )
        message ( FATAL_ERROR "URL must be specified!" )
    endif ()
    
    set ( CACHE_DIR "${PROJECT_BINARY_DIR}/_deps" )
    if ( FHD_CACHE_DIR )
        set ( CACHE_DIR "${FHD_CACHE_DIR}" )
        message ( "Setting cache dir to: ${CACHE_DIR}" )
    endif()

    FetchContent_Declare ( ${DEPNAME}
        URL "${FHD_URL}"
        DOWNLOAD_NO_PROGRESS TRUE
        DOWNLOAD_NO_EXTRACT TRUE
        PREFIX "${CACHE_DIR}"
    )

    __fetch_common ( ${DEPNAME} )
    return ( PROPAGATE "${DEPNAME}_FOLDER" )
endfunction ()
