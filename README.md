# cpp-init

This repo hosts configuration files for my C++ projects. In addition to `.clang-format`/`.clang-tidy` files, several CMake scripts exist for easy project setup and maintenance.

## Quickstart example

First, get the `get_cpp_init.cmake` script from the Releases page. Then you can include it in your project and it will fetch the rest of the scripts for you:

```cmake
cmake_minimum_required ( VERSION 3.26 )

# Use the script from releases to fetch everything
include ( "${PATH_TO}/get_cpp_init.cmake" )

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

# Applies .clang-format
enable_autoformatter ( ${PROJECT_NAME} )
```

With macros, this can get even shorter:

```cmake
cmake_minimum_required ( VERSION 3.26 )

# Use the script from releases to fetch everything
include ( "${PATH_TO}/get_cpp_init.cmake" )

# Read git tags for version
get_git_version ( PROJECT_VERSION_VARIABLE GIT_FULL_VERSION )

# Enable dependency management with CPM
bootstrap_cpm()

project ( demo VERSION ${GIT_PROJECT_VERSION} )

CPMAddPackage( "gh:nlohmann/json@3.11.2" )

# Assumes there is at least `src` directory in the current one (also looks for `include`)
# It globs them, adds them as sources, enables autoformatter and applies compile options.
make_executable ( ${PROJECT_NAME} DEPS nlohmann::json )
```

Assuming you're placing all `.cmake` files into a `cmake` subfolder, you can set a variable `CPP_INIT_ROOT_DIR` to `${CMAKE_CURRENT_SOURCE_DIR}/cmake` prior to including `get_cpp_init.cmake`. This will copy all related CMake scripts into your `cmake` folder so you can add them to your version control.

## bootstrap.cmake

This is a script full of useful utility functions:

### bootstrap_cpm

Downloads `CPM.cmake` and includes it. You can specify a particular version or stick with the latest:

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

Reads the current git version for use in project declarations and packaging.

```cmake
get_git_version (
	PROJECT_VERSION_VARIABLE GIT_PROJECT_VERSION
	FULL_VERSION_VARIABLE FULL_PROJECT_VERSION
)

# GIT_PROJECT_VERSION is <number>.<number>.<number>
project ( demo VERSION ${GIT_PROJECT_VERSION} )

# FULL_PROJECT_VERSION is the full output of `git describe` including the number of commits since the last tag and the current commit hash
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

Applies a set of useful compiler diagnostics and settings.

```cmake
apply_compile_options ( ${TARGET} )
```

### enable_autoformatter

Copies `.clang-format` to `${CMAKE_CURRENT_SOURCE_DIR}` and adds them to the specified target sources. In MSVC, you can press Alt F+K to format your code or install Format on Save extension.

```cmake
enable_autoformatter ( ${TARGET} )
```

### enable_linter

Copies `.clang-tidy` to `${CMAKE_CURRENT_SOURCE_DIR}` and adds them to the specified target sources. For MSVC, it turns on static code analysis with Clang tidy.

```cmake
enable_linter ( ${TARGET} )
```

## macros.cmake

### make_static_library

A shorthand for calling `glob_headers_and_sources`, `apply_compile_options` and bunch of other options. Declares `include` folder as public include directory.

Optionally you can specify a list of dependencies for public linkage.

```cmake
make_static_library ( myLib DEPS nlohmann_json::nlohmann_json )

# globs include/src folders
# applies compile options
# declares include folder as public include dir
# links nlohmann
# enables autoformatter
# ...
```

### make_executable

Similar as `make_static_library`, just for executables.
