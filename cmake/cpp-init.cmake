# Function: download_file_if_not_there
# Type: Function
# Description: Downloads a file from the internet if it doesn't exist locally. Creates an empty file as fallback if download fails.
# Arguments:
#   URL - Source URL to download from
#   TARGET - Local file path where the file should be saved
# Use Case: Useful for downloading configuration files, dependencies, or resources that should be cached locally
# Example:
#   download_file_if_not_there("https://example.com/config.json" "${CMAKE_BINARY_DIR}/config.json")
function ( download_file_if_not_there URL TARGET )
    if (NOT EXISTS ${TARGET})
        file (TOUCH ${TARGET})
        file (DOWNLOAD
            ${URL}
            ${TARGET}
        )
    endif()
endfunction()

# Function: bootstrap_cpm
# Type: Function
# Description: Downloads and includes the CPM (CMake Package Manager) for dependency management.
# Arguments:
#   VERSION (optional) - Specific CPM version to download (default: "latest")
# Use Case: Essential for projects using CPM for dependency management
# Example:
#   bootstrap_cpm()                    # Uses latest version
#   bootstrap_cpm(VERSION "v0.34.0")   # Uses specific version
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

# Macro: set_cpp23_x64
# Type: Macro
# Description: Configures the project for modern C++23 development with x64 architecture.
# Arguments: None
# Effects:
#   - Sets CMAKE_GENERATOR_PLATFORM to x64
#   - Sets CMAKE_CXX_STANDARD to 23
#   - Sets CMAKE_CXX_STANDARD_REQUIRED to ON
# Use Case: Standard configuration for modern C++ projects targeting 64-bit platforms
macro ( set_cpp23_x64 )
    set ( CMAKE_GENERATOR_PLATFORM     x64 )
    set ( CMAKE_CXX_STANDARD		   23 )
    set ( CMAKE_CXX_STANDARD_REQUIRED  ON )
endmacro () 

# Macro: cpp_init
# Type: Macro
# Description: Complete initialization of cpp-init toolkit with recommended defaults.
# Arguments: None
# Effects:
#   - Downloads and includes CPM package manager (bootstrap_cpm)
#   - Configures C++23/x64 settings (set_cpp23_x64)
# Use Case: One-line setup for new projects using cpp-init
# Example:
#   cpp_init()
#   # Now ready to use CPMAddPackage() and modern C++ features
macro( cpp_init )
    bootstrap_cpm()
    set_cpp23_x64()
endmacro ()

# Function: glob_headers_and_sources
# Type: Function
# Description: Automatically discovers project files and organizes them for IDE integration.
# Arguments:
#   HEADERS_OUTVARNAME - Variable name to store discovered header files
#   SOURCES_OUTVARNAME - Variable name to store discovered source files
# File Discovery Rules:
#   - Headers: include/**/*.{hpp,h} and private_include/**/*.{hpp,h}
#   - Sources: src/**/*.cpp and source/**/*.cpp
# Effects:
#   - Creates IDE source groups for better organization
#   - Populates output variables with file lists
# Behavior:
#   - New files automatically detected on build
#   - Removed files require manual CMake reconfiguration
# Example:
#   glob_headers_and_sources(MY_HEADERS MY_SOURCES)
#   add_executable(mytarget ${MY_HEADERS} ${MY_SOURCES})
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
        PRIVATE_HEADERS
        "${CMAKE_CURRENT_SOURCE_DIR}/private_include**/*.hpp"
    )
    
    file ( GLOB_RECURSE
        PRIVATE_HEADERS2
        "${CMAKE_CURRENT_SOURCE_DIR}/private_include**/*.h"
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
        FILES ${PRIVATE_HEADERS} ${PRIVATE_HEADERS2}
    )

    source_group(
        TREE "${CMAKE_CURRENT_SOURCE_DIR}"
        FILES ${LOCAL_SOURCES} ${LOCAL_SOURCES2}
    )

    set ( ${HEADERS_OUTVARNAME} "${LOCAL_HEADERS};${LOCAL_HEADERS2};${PRIVATE_HEADERS};${PRIVATE_HEADERS2}" PARENT_SCOPE )
    set ( ${SOURCES_OUTVARNAME} "${LOCAL_SOURCES};${LOCAL_SOURCES2}" PARENT_SCOPE )
endfunction ()

# Function: get_version_from_git
# Type: Function
# Description: Extracts semantic version from Git tags for automated project versioning.
# Arguments:
#   PROJECT_VERSION_VARIABLE - Variable to store semantic version (e.g., "1.2.3")
#   FULL_VERSION_VARIABLE (optional) - Variable to store full git describe output
# Requirements:
#   - Git repository with tagged releases
#   - Tags following semantic versioning (optional 'v' prefix supported)
# Behavior:
#   - Executes 'git describe --tags' to get version info
#   - Extracts semantic version using regex pattern
#   - Supports tags like 'v1.0.0' or '1.0.0'
# Use Case: Automatic version management synchronized with Git releases
# Example:
#   get_version_from_git(
#       PROJECT_VERSION_VARIABLE GIT_PROJECT_VERSION
#       FULL_VERSION_VARIABLE GIT_FULL_VERSION
#   )
#   project(MyApp VERSION ${GIT_PROJECT_VERSION})
function ( get_version_from_git )
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
# Type: Function
# Description: Downloads and unpacks prebuilt libraries from archives, bypassing compilation time.
# Arguments:
#   DEPNAME - Dependency name (creates ${DEPNAME}_FOLDER variable)
# Named Parameters:
#   URL - Archive URL to download (required)
#   CACHE_DIR - Custom cache directory (optional, default: ${PROJECT_BINARY_DIR}/_deps)
# Behavior:
#   - Downloads and extracts archive using FetchContent
#   - Does NOT call add_subdirectory() on extracted content
#   - Creates ${DEPNAME}_FOLDER variable pointing to extracted location
# Use Case: Ideal for large libraries (e.g., SFML) that provide precompiled releases
# Example:
#   fetch_prebuilt_dependency(SFML
#       URL https://github.com/SFML/SFML/releases/download/2.6.1/SFML-2.6.1-windows-vc17-64-bit.zip
#       CACHE_DIR "C:/deps"
#   )
#   target_include_directories(myapp PRIVATE ${SFML_FOLDER}/include)
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
        SOURCE_SUBDIR "does-not-exist"
    )

    __fetch_common ( ${DEPNAME} )
    return ( PROPAGATE "${DEPNAME}_FOLDER" )
endfunction ()

# Function: fetch_headeronly_dependency
# Type: Function
# Description: Downloads single header-only library files directly from URLs.
# Arguments:
#   DEPNAME - Dependency name (creates ${DEPNAME}_FOLDER variable)
# Named Parameters:
#   URL - Direct URL to header file (required)
#   CACHE_DIR - Custom cache directory (optional, default: ${PROJECT_BINARY_DIR}/_deps)
# Behavior:
#   - Downloads file without extraction (DOWNLOAD_NO_EXTRACT)
#   - Creates ${DEPNAME}_FOLDER variable pointing to download location
# Use Case: Perfect for single-header libraries like nlohmann/json, stb libraries
# Example:
#   fetch_headeronly_dependency(JSON
#       URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp
#   )
#   target_include_directories(myapp PRIVATE ${JSON_FOLDER})
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

# Function: apply_compile_options
# Type: Function
# Description: Applies recommended compiler flags and diagnostic settings for high-quality code.
# Arguments:
#   TARGET - CMake target name to configure
# Platform Support: Currently MSVC only
# MSVC Settings Applied:
#   /W4 - High warning level
#   /MP - Multi-processor compilation
#   /we4265 - Missing virtual destructor (error)
#   /we4834 - Discarding [[nodiscard]] result (error)
#   /we4456-4459 - Name shadowing (error)
#   /we4369 - Enum value overflow (error)
#   /we5205 - Non-virtual interface destructor (error)
# Effects:
#   - Debug builds get "-d" postfix for easy identification
# Use Case: Enforces high code quality standards and catches common mistakes
function ( apply_compile_options TARGET )
	if ( ${MSVC} )
		target_compile_options ( ${TARGET}
			PRIVATE
			/W4
			/MP
			/we4265 # Missing virtual dtor
			/we4834 # Discarding result of [[nodiscard]] function
			/we4456 # Name shadowing
			/we4457 # Name shadowing
			/we4458 # Name shadowing
			/we4459 # Name shadowing
			# /wd4251
			/we4369 # value of enum overflows underlying type
			/we5205 # Dtor on iface is not virtual
		)
		
		set_target_properties(
			${TARGET} PROPERTIES
			DEBUG_POSTFIX "-d"
		)
		
	else ()
		message ( "apply_compile_options: no options for non-msvc compiler" )
	endif ()
endfunction ()

# Function: enable_autoformatter
# Type: Function
# Description: Integrates clang-format for consistent code formatting across the project.
# Arguments:
#   TARGET - CMake target name to configure
# Actions:
#   - Downloads and copies .clang-format configuration to project directory
#   - Adds format file to target sources (visible in IDE)
# IDE Integration:
#   - Visual Studio: Use Alt+K+F to format or enable "Format on Save" extension
# Use Case: Ensures consistent code style across team and CI/CD
function ( enable_autoformatter TARGET )
	file ( COPY_FILE
		"${CLANG_FORMAT_PATH}"
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-format"
	)

	target_sources ( ${TARGET} PRIVATE 
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-format"
	)
endfunction ()

# Function: enable_linter
# Type: Function
# Description: Integrates clang-tidy static analysis for code quality and bug detection.
# Arguments:
#   TARGET - CMake target name to configure
# Platform Support: MSVC integration only
# Actions:
#   - Downloads and copies .clang-tidy configuration to project directory
#   - Adds tidy file to target sources (visible in IDE)
#   - Configures Visual Studio to use clang-tidy for static analysis
# Note: Consider installing a newer clang-tidy version than MSVC's default
# Use Case: Catches potential bugs, enforces coding standards, improves code quality
function ( enable_linter TARGET )
	file ( COPY_FILE
		"${CLANG_TIDY_PATH}"
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy"
	)

	target_sources ( ${TARGET} PRIVATE 
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy"
	)

	if ( ${MSVC} )
		set_target_properties ( ${TARGET} PROPERTIES
			VS_GLOBAL_RunCodeAnalysis true
			VS_GLOBAL_EnableMicrosoftCodeAnalysis false
			VS_GLOBAL_EnableClangTidyCodeAnalysis true
		)
	else ()
		message ( "enable_linter: no options for non-msvc compiler" )
	endif ()
endfunction ()

# Macro: link_public_header_folder
# Type: Macro
# Description: Links the include/ directory as a PUBLIC include path if it exists.
# Arguments:
#   TARGET - CMake target name to configure
# Behavior: Only adds include directory if the include/ folder exists
# Use Case: Used internally by make_static_library for automatic header linking
macro ( link_public_header_folder TARGET )
    if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories( ${TARGET} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" )
    endif ()
endmacro ()

# Macro: link_private_header_folder
# Type: Macro
# Description: Links the private_include/ directory as a PRIVATE include path if it exists.
# Arguments:
#   TARGET - CMake target name to configure
# Behavior: Only adds include directory if the private_include/ folder exists
# Use Case: Used internally by make_static_library and make_executable for internal headers
macro ( link_private_header_folder TARGET )
    if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/private_include")
        target_include_directories( ${TARGET} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/private_include" )
    endif ()
endmacro ()

# Macro: make_static_library
# Type: Macro
# Description: Creates a static library target with all cpp-init best practices applied automatically.
# Arguments:
#   TARGET - Library target name
# Options:
#   ENABLE_LINTER - Enable clang-tidy static analysis
# Named Parameters:
#   DEPS - List of dependencies to link publicly
# Automatic Actions:
#   ✓ Globs headers and sources (glob_headers_and_sources)
#   ✓ Creates static library target
#   ✓ Links public headers (include/ → PUBLIC)
#   ✓ Links private headers (private_include/ → PRIVATE)
#   ✓ Links dependencies (if specified)
#   ✓ Applies compiler options (apply_compile_options)
#   ✓ Enables autoformatting (enable_autoformatter)
#   ✓ Enables linting (if ENABLE_LINTER specified)
# Use Case: One-line library creation with all best practices
# Example:
#   make_static_library(MyLib DEPS nlohmann_json::nlohmann_json ENABLE_LINTER)
macro ( make_static_library TARGET )
    set ( options ENABLE_LINTER )
    set ( multiValueArgs DEPS )

    cmake_parse_arguments ( CIMSL "${options}" "" "${multiValueArgs}" ${ARGN} )

    glob_headers_and_sources ( HEADERS SOURCES )

    add_library( ${TARGET} STATIC ${HEADERS} ${SOURCES} )

    link_public_header_folder ( ${TARGET} )
    link_private_header_folder ( ${TARGET} )

    if ( CIMSL_DEPS )
        target_link_libraries ( ${TARGET} PUBLIC ${CIMSL_DEPS} )
    endif ()

    if ( CIMSL_ENABLE_LINTER )
        enable_linter ( ${TARGET} )
    endif ()

    enable_autoformatter ( ${TARGET} )
    apply_compile_options ( ${TARGET} )
endmacro()

# Macro: make_executable
# Type: Macro
# Description: Creates an executable target with all cpp-init best practices applied automatically.
# Arguments:
#   TARGET - Executable target name
# Options:
#   ENABLE_LINTER - Enable clang-tidy static analysis
# Named Parameters:
#   DEPS - List of dependencies to link
# Automatic Actions:
#   ✓ Globs headers and sources (glob_headers_and_sources)
#   ✓ Creates executable target
#   ✓ Links public headers (include/ → PUBLIC)
#   ✓ Links private headers (private_include/ → PRIVATE)
#   ✓ Links dependencies (if specified)
#   ✓ Applies compiler options (apply_compile_options)
#   ✓ Enables autoformatting (enable_autoformatter)
#   ✓ Enables linting (if ENABLE_LINTER specified)
# Use Case: One-line executable creation with all best practices
# Example:
#   make_executable(MyApp DEPS MyLib Catch2::Catch2WithMain ENABLE_LINTER)
macro ( make_executable TARGET )
    set( options ENABLE_LINTER )
    set( multiValueArgs DEPS )

    cmake_parse_arguments ( CIME "${options}" "" "${multiValueArgs}" ${ARGN} )

    glob_headers_and_sources ( HEADERS SOURCES )

    add_executable( ${TARGET} ${HEADERS} ${SOURCES} )

    link_public_header_folder ( ${TARGET} )
    link_private_header_folder ( ${TARGET} )

    if ( CIME_DEPS )
        target_link_libraries ( ${TARGET} PUBLIC ${CIME_DEPS} )
    endif ()

    if ( CIME_ENABLE_LINTER )
        enable_linter ( ${TARGET} )
    endif ()

    enable_autoformatter ( ${TARGET} )
    apply_compile_options ( ${TARGET} )
endmacro()

### === BOOTSTRAPPING === ###
# Configuration for downloading cpp-init resources
# CPP_INIT_REF controls which version of cpp-init resources to download
# Options:
#   - "heads/main" - Latest development version
#   - "tags/vX.Y.Z" - Specific release version
set ( CPP_INIT_REF "heads/main" )
# set ( CPP_INIT_REF "tags/v0.5.0" )

set ( CLANG_FORMAT_PATH "${CMAKE_BINARY_DIR}/.clang-format" )
download_file_if_not_there (
    "https://raw.githubusercontent.com/nerudaj/cpp-init/refs/${CPP_INIT_REF}/.clang-format"
    "${CLANG_FORMAT_PATH}"
)

set ( CLANG_TIDY_PATH "${CMAKE_BINARY_DIR}/.clang-tidy" )
download_file_if_not_there (
    "https://raw.githubusercontent.com/nerudaj/cpp-init/refs/${CPP_INIT_REF}/.clang-tidy"
    "${CLANG_TIDY_PATH}"
)