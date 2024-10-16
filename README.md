# cpp-init

This repo hosts configuration files for my C++ projects. Aside from a `.clang-format` file, there is a bunch of CMake scripts for easy setup and maintenance of my projects.

## Quickstart example

```cmake
cmake_minimum_required ( VERSION 3.26 )

# Use the script from releases to fetch everything
include ( "${CMAKE_CURRENT_SOURCE_DIR}/get_cpp_init.cmake" )

# Read git tags for version
get_git_version ( PROJECT_VERSION_VARIABLE GIT_FULL_VERSION )

# Enable dependency management with CPM
bootstrap_cpm()

project ( demo VERSION ${GIT_PROJECT_VERSION} )

CPMAddPackage( "gh:nlohmann/json@3.11.2" )

# globs all .hpp files from "${CMAKE_CURRENT_SOURCE_DIR}/include"
# and all .cpp files from "${CMAKE_CURRENT_SOURCE_DIR}/src"
# including subfolders
glob_headers_and_sources ( HEADERS SOURCES ) 

add_executable ( ${PROJECT_NAME}
	${HEADERS}
	${SOURCES}
)

target_link_libraries ( ${PROJECT_NAME}
	PRIVATE_LINK nlohmann::json
)

# Applies compiler switches and options I commonly use
apply_compile_options ( ${PROJECT_NAME} )

# Applies .clang-format and .clang-tidy
enable_autoformat_and_linter ( ${PROJECT_NAME} )
```

## How to use

You can either use `get_cpp_init.cmake` script that is available on the Releases page, or you can add this repo as a subrepo or you can use CMake's FetchContent to get it (that's what the script does):

```cmake
cmake_minimum_required ( VERSION 3.26 )

include ( FetchContent )

FetchContent_Declare (
	cpp-init
	GIT_REPOSITORY https://github.com/nerudaj/cpp-init
)

FetchContent_MakeAvailable( cpp-init )

# Make utility functions available
include ( "${cppinit_folder}/cmake/bootstrap.cmake" )

# Set up C++ standard, compiler flags, etc
include ( "${cppinit_folder}/cmake/cpp.cmake" )
```

## bootstrap.cmake

This is a script full of useful utility functions:

### bootstrap_cpm

Downloads `CPM.cmake` and includes it. You can specify a particular version or stick with latest:

```cmake
include ( "${cppinit_folder}/cmake/bootstrap.cmake" )

bootstrap_cpm ( 0.30.2 ) # version number is optional

# CPM can now be used
CPMAddPackage( "gh:nlohmann/json@3.11.2" )
```

### glob_headers_and_sources

If the `${CMAKE_CURRENT_SOURCE_DIR}` contains subfolders `include` and `src`, this will recursively glob all `.hpp` files in the `include` folder and all `.cpp` files in the `src` folder. It will add them to your IDE filters through `source_group` call and it will populate the output variables.

```cmake
glob_headers_and_sources ( HEADER_FILES SOURCE_FILES )

add_executable ( mytarget
	${HEADER_FILES}
	${SOURCE_FILES
)
```

Just know that newly added files will be automatically found on subsequent builds while if you remove a file, you need to reconfigure manually.

### get_git_version

Reads the current git version for use in project declarations and packaing.

```cmake
get_git_version (
	PROJECT_VERSION_VARIABLE GIT_PROJECT_VERSION
	FULL_VERSION_VARIABLE FULL_PROJECT_VERSION
)

# GIT_PROJECT_VERSION is <number>.<number>.<number>
project ( demo VERSION ${GIT_PROJECT_VERSION} )

# FULL_PROJECT_VERSION is the full output of `git describe` including number of commits since last tag and current commit hash
```

The version is read from git tags using `git describe`. Tagname is allowed to be prefixed with `v`. This prefix will be stripped from the short project version.

### fetch_prebuilt_dependency

CPM is great, but you pay with long build times. Many libraries on GitHub come packaged for you in the Releases tab, so we can download them easily:

```cmake
fetch_prebuilt_dependency (
	SFML
	URL https://github.com/SFML/SFML/releases/download/2.6.1/SFML-2.6.1-windows-vc17-64-bit.zip
	CACHE_DIR "C:/deps" # can download to outside location
)

# unpacked archive contents are in ${SFML_FOLDER}
```

### fetch_headeronly_dependency

For headeronly libraries, it is even easier (the `CACHE_DIR` parameter can still be used).

```cmake
fetch_headeronly_dependency (
	NLOHMANN_JSON 
	URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp
)

# json.hpp is located in ${NLOHMANN_JSON_FOLDER}
```

## cpp.cmake

### apply_compile_options

**NOTE:** Currently only supported with MSVC generator.

Applies set of useful compiler diagnostics and settings.

```cmake
apply_compile_options ( ${TARGET} )
```

### enable_autoformat_and_linter

Copies `.clang-format` and `.clang-tidy` to `${CMAKE_CURRENT_SOURCE_DIR}` and adds them to the specified target sources.

```cmake
enable_autoformat_and_linter ( ${TARGET} )
```

That's enough to turn on clang format in MSVC. For clang tidy, it also enables code analysis with clang-tidy in MSVC and the rest of the configuration is handled by the config file.
