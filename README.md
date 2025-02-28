# cpp-init

This repo hosts common configuration files I use in my C++ projects, namely:

 * `.clang-format`
 * `.clang-tidy`
 * `cmake/cpp-init.cmake`

The `cpp-init.cmake` is an opinionated CMake helper that makes CMake much simpler by enforcing a bunch of rules on project structure.

## Table of Contents

 * [Project Structure](#project-structure)
 * [Quickstart Example](#quickstart-example)
 * [Documentation](#documentation)
 * [CMake Package Manager](#cmake-package-manager)

## Project Structure

For each compilable target, the recommended folder structure is this:

```
\root
	- \include
		- File.hpp
	- \src
		- File.cpp
	- CMakeLists.txt
```

Scripts present in this repo are conditioned to follow this structure, with a little bit of leevay. The `src` folder can also be called `source`. Allowed extensions for header files are `hpp` and `h`. Header files must always be in a folder `include` or `private_include` (the latter is for headers that should not be accessible by dependent targets).

These scripts also rely on globbing (recursively scanning) for source files, instead of you having to manually specify them in CMakeLists.txt. This makes project maintenance much easier, but if you delete a file, `cmake --build` command will not detect it automatically and will fail compilation.

If you delete a source file, you always need to manually reconfigure. Lastly, scripts here are tailored towards MSVC. PRs for your favorite platforms are welcomed.

### Semantic versioning

This project also promotes [semantic versioning](https://semver.org/). You can easily read the current version from the git tags, insert it into your project declaration and it will propagate further into packaging, etc.

If you're new to git, you can mark the current commit with version like this:

```sh
git tag v0.1.0
git push --tags
```

## Quickstart Example

Suppose you want to make a simple executable with a bunch of header and source files. Follow this folder structure:

```
\root
	- \cmake
		- cpp-init.cmake
	- \include
		- HeaderA.hpp
		- HeaderB.hpp
	- \src
		- ImplA.cpp
		- ImplB.cpp
		- Main.cpp
	- CMakeLists.txt
```

Obtain the `cpp-init.cmake` by downloading the latest version from the [Releases](https://github.com/nerudaj/cpp-init/releases/latest) page.

Put the following code in the `CMakeLists.txt`:

```cmake
cmake_minimum_required ( VERSION 3.26 )

include ( "cmake/cpp-init.cmake" )

cpp_init()
get_version_from_git ( PROJECT_VERSION_VARIABLE GIT_FULL_VERSION )

project ( Example VERSION ${PROJECT_VERSION_VARIABLE} )

CPMAddPackage ( "gh:nlohmann/json@3.11.2" )

make_executable ( ${PROJECT_NAME} DEPS nlohmann_json::nlohmann_json )
```

The `cpp_init()`, `get_version_from_git()`, and `make_executable()` are all from the `cpp-init.cmake` and are documented below.

This example autodetects header and source files in the appropriate folders, creates an executable target called `${PROJECT_NAME}` and links nlohmann JSON library to it. It also reads project semantic version from git tags and applies it to the project.

## Documentation

This section describes utility functions present in the `cpp-init.cmake` file.

### download_file_if_not_there

If a file with a TARGET name is not yet present, this function attepts to download it from a given URL. If not successful, empty file is created instead.

```cmake
download_file_if_not_there (
	"http://myurl.com/file.txt"
	"${CMAKE_BINARY_DIR}/file.txt"
)
```

### bootstrap_cpm

Downloads `CPM.cmake` and includes it. You can specify a particular version or stick with the latest:

```cmake
include ( "${cppinit_folder}/cmake/bootstrap.cmake" )

bootstrap_cpm ( 0.30.2 ) # version number is optional

# CPM can now be used
CPMAddPackage( "gh:nlohmann/json@3.11.2" )
```

### set_cpp23_x64

Sets the required C++ standard to 23 and sets the target platform to x64.

### cpp_init

Shorthand for calling `bootstrap_cpm` and `set_cpp23_x64`.

### glob_headers_and_sources

In current source directory, recursively looks for .h/.hpp files in folders `include` and `private_include`, adds them to IDE through `source_group` call and saves them in `HEADERS_OUTVARNAME` variable.

Also looks for .cpp files in `source` and `src` folders, adds them to IDE and saves them in `SOURCES_OUTVARNAME`.

If the `${CMAKE_CURRENT_SOURCE_DIR}` contains subfolders `include` and `src`, this will recursively glob all `.hpp` files in the `include` folder and all `.cpp` files in the `src` folder. It will add them to your IDE filters through `source_group` call and it will populate the output variables.

```cmake
glob_headers_and_sources ( HEADER_FILES SOURCE_FILES )

add_executable ( mytarget
	${HEADER_FILES}
	${SOURCE_FILES}
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
	CACHE_DIR "C:/deps" # optional: can download to given location
)

# unpacked archive contents are in ${SFML_FOLDER}
```

Unlike `FetchContent_MakeAvailable`, this only downloads and unpacks the archive. It does not look for `CMakeLists.txt` inside the archive, nor it calls `add_subdirectory`.

### fetch_headeronly_dependency

Downloads a single file, presumably a headeronly library.

```cmake
fetch_headeronly_dependency (
	JSON 
	URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp
	CACHE_DIR "C:/deps" # optional: can download to given location
)

# json.hpp is located in ${JSON_FOLDER}
```

### apply_compile_options

**NOTE:** Currently only supported with MSVC generator.

Applies a set of useful compiler diagnostics and settings. For MSVC, postfixes all artifacts compiled under Debug with `-d` postfix.

```cmake
apply_compile_options ( ${TARGET} )
```

### enable_autoformatter

Copies `.clang-format` to `${CMAKE_CURRENT_SOURCE_DIR}` and adds them to the specified target sources. In MSVC, you can press Alt F+K to format your code or install Format on Save extension.

```cmake
enable_autoformatter ( ${TARGET} )
```

### enable_linter

Copies `.clang-tidy` to `${CMAKE_CURRENT_SOURCE_DIR}` and adds them to the specified target sources. For MSVC, it turns on static code analysis with clang-tidy. Note that MSVC ships with some old clang-tidy implementation so you likely need to install newer one yourself.

```cmake
enable_linter ( ${TARGET} )
```

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

## CMake Package Manager

CPM is great, but I can never remember the author nor the CMake target I can link against. Here's a list of bunch of libraries I frequently use, might be useful for you as well:

| Library name | Version | CPM expression | Linkable target |
| --- | --- | --- | --- |
| base64 | master | `gh:tobiaslocker/base64#master` | base64 |
| Catch2 | 3.7.1 | `gh:catchorg/Catch2#v3.7.1` | Catch2::Catch2 |
| cxxopts | 3.2.1 | `jarro2783/cxxopts#3.2.1` | cxxopts |
| dgm-lib | 2.5.0 | `gh:nerudaj/dgm-lib#v2.5.0` | dgm-lib |
| dgm-lib 3 | 3.0.0-rc1 | `gh:nerudaj/dgm-lib#v3.0.0-rc1` | dgm::dgm |
| Eigen | master | `gl:libeigen/eigen#master` | Eigen3::Eigen |
| EnTT | 3.14.0 | `gh:skypjack/entt#v3.14.0` | EnTT::EnTT |
| FakeIt | 2.4.1 | `gh:eranpeer/FakeIt#2.4.1` | FakeIt::FakeIt |
| fsm-lib | 2.1.0 | `gh:nerudaj/fsm-lib#v2.1.0` | fsm-lib |
| nlohmann json | 3.11.3 | `gh:nlohmann/json#v3.11.3` | nlohmann::json |
| SFML | 2.6.1 | `gh:SFML/SFML#2.6.1` | sfml-main sfml-audio sfml-graphics sfml-window sfml-network |
| SFML 3 | 3.0.0 | `gh:SFML/SFML#3.0.0` | SFML::Main SFML::Audio SFML::Graphics SFML::Window SFML::Network |