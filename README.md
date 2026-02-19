# cpp-init

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![C++](https://img.shields.io/badge/C%2B%2B-23-blue.svg)
![CMake](https://img.shields.io/badge/CMake-3.26%2B-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)

**cpp-init** is a opinionated C++ project initialization toolkit that streamlines the setup and development of modern C++ projects. It provides:

- 🚀 **Project Scaffolding**: Automated project structure generation with `cpp-init.bat`
- 📦 **CMake Utilities**: Opinionated CMake helper (`cpp-init.cmake`) that simplifies project configuration
- 🔧 **Development Tools**: Pre-configured `.clang-format` and `.clang-tidy` for consistent code style
- 📚 **Dependency Management**: Integration with CPM (CMake Package Manager) for easy library inclusion
- 🏷️ **Version Management**: Automatic semantic versioning from Git tags

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
  - [Using cpp-init.bat (Recommended)](#using-cpp-initbat-recommended)
  - [Manual Setup](#manual-setup)
- [Project Structure](#project-structure)
- [Usage Examples](#usage-examples)
- [API Documentation](#api-documentation)  
- [CMake Package Manager](#cmake-package-manager)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Download from Releases (Recommended)

1. Download the latest release from the [Releases page](https://github.com/nerudaj/cpp-init/releases/latest)
2. Extract the archive to your desired location
3. Add the location to your PATH (optional, for global access to `cpp-init.bat`)

### Clone from Source

```bash
git clone https://github.com/nerudaj/cpp-init.git
cd cpp-init
```

## Quick Start

### Using cpp-init.bat (Recommended)

The fastest way to get started is using the included batch script that automatically scaffolds your project:

```bash
# Navigate to your projects directory
cd /path/to/your/projects

# Run the initialization script
cpp-init.bat
```

The script will prompt you for:
- **Project name**: The name of your project
- **Library target**: Whether to create a library component (y/n)

This automatically creates:
- ✅ Proper folder structure (`bin/`, `lib/`, `tests/`)  
- ✅ Downloads latest `cpp-init.cmake`
- ✅ Generates `CMakeLists.txt` files
- ✅ Sets up semantic versioning from Git

**Example output structure:**
```
MyProject/
├── cmake/
│   └── cpp-init.cmake         # Downloaded automatically
├── bin/                       # Executable target
│   ├── include/
│   ├── src/
│   └── CMakeLists.txt
├── lib/                       # Library target (if requested)
│   ├── include/
│   ├── src/
│   └── CMakeLists.txt  
├── tests/                     # Test target (if library requested)
│   ├── include/
│   ├── src/
│   └── CMakeLists.txt
└── CMakeLists.txt             # Root CMake file
```

### Manual Setup

If you prefer manual setup or need more control:

1. Download `cpp-init.cmake` from the [Releases page](https://github.com/nerudaj/cpp-init/releases/latest)
2. Place it in your project's `cmake/` directory
3. Follow the [project structure guidelines](#project-structure) below
4. See [usage examples](#usage-examples) for CMakeLists.txt setup

## Project Structure

cpp-init enforces a consistent, scalable project structure that works well for both small utilities and large applications:

### Standard Layout

```
project-root/
├── cmake/
│   └── cpp-init.cmake          # CMake utilities
├── include/                    # Public headers
│   └── MyHeader.hpp            
├── src/                        # Source files (or 'source/')
│   ├── MyImplementation.cpp
│   └── main.cpp
├── private_include/            # Private headers (optional)
│   └── Internal.hpp
└── CMakeLists.txt
```

### Multi-Target Project Layout

```
project-root/
├── cmake/
│   └── cpp-init.cmake
├── bin/                        # Executable target
│   ├── include/
│   ├── src/
│   │   └── main.cpp
│   └── CMakeLists.txt
├── lib/                        # Library target  
│   ├── include/
│   │   └── MyLib.hpp
│   ├── src/
│   │   └── MyLib.cpp
│   └── CMakeLists.txt
├── tests/                      # Test target
│   ├── include/
│   ├── src/
│   │   └── test_main.cpp
│   └── CMakeLists.txt
└── CMakeLists.txt              # Root configuration
```

### Folder Rules

- **Headers**: Must be in `include/` (public) or `private_include/` (internal)
- **Sources**: Must be in `src/` or `source/`
- **Extensions**: `.hpp` and `.h` for headers, `.cpp` for sources
- **Auto-detection**: Files are found automatically via globbing (no manual listing required)
- **File Changes**: Adding files is automatic, removing files requires CMake reconfiguration

### Semantic Versioning

cpp-init promotes [semantic versioning](https://semver.org/) using Git tags:

```bash
# Tag your releases
git tag v1.0.0
git push --tags

# Version automatically available in CMake
```

## Usage Examples

### Simple Executable

Create a basic executable project with external dependencies:

```cmake
cmake_minimum_required(VERSION 3.26)

include("cmake/cpp-init.cmake")

cpp_init()
get_version_from_git(PROJECT_VERSION_VARIABLE GIT_FULL_VERSION)

project(MyApp VERSION ${PROJECT_VERSION_VARIABLE})

# Add dependencies via CPM
CPMAddPackage("gh:nlohmann/json@3.11.3")
CPMAddPackage("gh:fmtlib/fmt@10.1.1")

# Create executable with automatic file detection
make_executable(${PROJECT_NAME} 
    DEPS nlohmann_json::nlohmann_json fmt::fmt
)
```

### Library with Tests

Create a static library and test executable:

```cmake
# Root CMakeLists.txt
cmake_minimum_required(VERSION 3.26)

include("cmake/cpp-init.cmake")
cpp_init()
get_version_from_git(PROJECT_VERSION_VARIABLE GIT_FULL_VERSION)

project(MyLibrary VERSION ${PROJECT_VERSION_VARIABLE})

enable_testing()

add_subdirectory(lib)
add_subdirectory(bin)        # Example executable using the library  
add_subdirectory(tests)
```

```cmake
# lib/CMakeLists.txt  
make_static_library(${PROJECT_NAME}
    DEPS nlohmann_json::nlohmann_json
)
```

```cmake
# tests/CMakeLists.txt
CPMAddPackage("gh:catchorg/Catch2@v3.7.1")

make_executable(${PROJECT_NAME}_tests
    DEPS ${PROJECT_NAME} Catch2::Catch2WithMain
)

include(CTest)
include(Catch)
catch_discover_tests(${PROJECT_NAME}_tests)
```

### Advanced Configuration

Using multiple features together:

```cmake
cmake_minimum_required(VERSION 3.26)

include("cmake/cpp-init.cmake")

# Initialize with custom C++ standard
set_cpp23_x64()
bootstrap_cpm()

get_version_from_git(
    PROJECT_VERSION_VARIABLE GIT_PROJECT_VERSION
    FULL_VERSION_VARIABLE GIT_FULL_VERSION  
)

project(AdvancedProject VERSION ${GIT_PROJECT_VERSION})

# Fetch prebuilt dependencies
fetch_prebuilt_dependency(
    SFML
    URL https://github.com/SFML/SFML/releases/download/2.6.1/SFML-2.6.1-windows-vc17-64-bit.zip
    CACHE_DIR "C:/deps"
)

# Manual target creation with all bells and whistles
glob_headers_and_sources(HEADERS SOURCES)

add_executable(${PROJECT_NAME} ${HEADERS} ${SOURCES})
apply_compile_options(${PROJECT_NAME})
enable_autoformatter(${PROJECT_NAME})
enable_linter(${PROJECT_NAME})

target_include_directories(${PROJECT_NAME} PRIVATE ${SFML_FOLDER}/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${SFML_FOLDER}/lib)
target_link_libraries(${PROJECT_NAME} PRIVATE sfml-graphics sfml-window sfml-system)
```

## API Documentation

This section describes utility functions and macros present in the `cpp-init.cmake` file.

### Core Initialization Functions

#### `cpp_init()`

**Description**: Initializes cpp-init by bootstrapping CPM package manager and setting C++23/x64 configuration.  
**Type**: Macro  
**Arguments**: None  

```cmake
cpp_init()
# Equivalent to calling bootstrap_cpm() and set_cpp23_x64()
```

#### `bootstrap_cpm([VERSION version])`

**Description**: Downloads and includes the CPM.cmake package manager.  
**Type**: Function  
**Arguments**:  
- `VERSION` (optional): Specific CPM version to download (default: "latest")

```cmake
bootstrap_cpm()                    # Uses latest version
bootstrap_cpm(VERSION "v0.34.0")   # Uses specific version

# CPM is now available
CPMAddPackage("gh:nlohmann/json@3.11.3")
```

#### `set_cpp23_x64()`

**Description**: Configures project for C++23 standard with x64 platform.  
**Type**: Macro  
**Arguments**: None  

```cmake
set_cpp23_x64()
# Sets CMAKE_GENERATOR_PLATFORM=x64, CMAKE_CXX_STANDARD=23
```

### File Discovery and Versioning

#### `glob_headers_and_sources(HEADERS_VAR SOURCES_VAR)`

**Description**: Automatically discovers and organizes project files into IDE source groups.  
**Type**: Function  
**Arguments**:  
- `HEADERS_VAR`: Variable name to store discovered header files
- `SOURCES_VAR`: Variable name to store discovered source files  

**File Discovery Rules**:  
- Headers: `include/**/*.{hpp,h}` and `private_include/**/*.{hpp,h}`  
- Sources: `src/**/*.cpp` and `source/**/*.cpp`  
- Automatically creates IDE source groups  
- New files detected on build; removed files require reconfiguration  

```cmake
glob_headers_and_sources(MY_HEADERS MY_SOURCES)

add_executable(mytarget ${MY_HEADERS} ${MY_SOURCES})
```

#### `get_version_from_git(PROJECT_VERSION_VARIABLE var [FULL_VERSION_VARIABLE full_var])`

**Description**: Extracts semantic version from Git tags for project versioning.  
**Type**: Function  
**Arguments**:  
- `PROJECT_VERSION_VARIABLE`: Variable to store semantic version (e.g., "1.2.3")  
- `FULL_VERSION_VARIABLE` (optional): Variable to store full git describe output  

**Requirements**: Git repository with tagged releases (supports optional 'v' prefix)

```cmake
get_version_from_git(
    PROJECT_VERSION_VARIABLE GIT_PROJECT_VERSION
    FULL_VERSION_VARIABLE GIT_FULL_VERSION
)

project(MyApp VERSION ${GIT_PROJECT_VERSION})
# GIT_PROJECT_VERSION = "1.2.3" 
# GIT_FULL_VERSION = "v1.2.3-5-g1234abc" (full git describe)
```

### Dependency Management

#### `fetch_prebuilt_dependency(DEPNAME URL url [CACHE_DIR dir])`

**Description**: Downloads and unpacks prebuilt libraries from GitHub releases, bypassing compilation time.  
**Type**: Function  
**Arguments**:  
- `DEPNAME`: Dependency name (creates `${DEPNAME}_FOLDER` variable)  
- `URL`: Download URL for the archive  
- `CACHE_DIR` (optional): Custom cache location (default: `${PROJECT_BINARY_DIR}/_deps`)  

**Use Case**: Ideal for large libraries like SFML that provide precompiled releases  
**Note**: Only downloads and extracts; does not call `add_subdirectory()`  

```cmake
fetch_prebuilt_dependency(
    SFML
    URL https://github.com/SFML/SFML/releases/download/2.6.1/SFML-2.6.1-windows-vc17-64-bit.zip
    CACHE_DIR "C:/deps"
)

# Use extracted content
target_include_directories(myapp PRIVATE ${SFML_FOLDER}/include)
target_link_directories(myapp PRIVATE ${SFML_FOLDER}/lib)
```

#### `fetch_headeronly_dependency(DEPNAME URL url [CACHE_DIR dir])`

**Description**: Downloads single header-only files from URLs.  
**Type**: Function  
**Arguments**:  
- `DEPNAME`: Dependency name (creates `${DEPNAME}_FOLDER` variable)  
- `URL`: Direct URL to header file  
- `CACHE_DIR` (optional): Custom cache location (default: `${PROJECT_BINARY_DIR}/_deps`)  

**Use Case**: Perfect for single-header libraries  

```cmake
fetch_headeronly_dependency(
    JSON
    URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp
)

target_include_directories(myapp PRIVATE ${JSON_FOLDER})
```

#### `download_file_if_not_there(URL TARGET)`

**Description**: Downloads a file only if it doesn't exist locally; creates empty file if download fails.  
**Type**: Function  
**Arguments**:  
- `URL`: Source URL
- `TARGET`: Local file path  

```cmake
download_file_if_not_there(
    "https://example.com/config.json"
    "${CMAKE_BINARY_DIR}/config.json"
)
```

### Development Tools

#### `apply_compile_options(TARGET)`

**Description**: Applies recommended compiler flags and diagnostic settings.  
**Type**: Function  
**Platform**: Currently MSVC only  
**Arguments**:  
- `TARGET`: CMake target name  

**MSVC Settings**:  
- `/W4`: High warning level  
- `/MP`: Multi-processor compilation  
- Elevated warnings for common issues (shadowing, missing virtual destructors, etc.)  
- Debug builds get `-d` postfix  

```cmake
apply_compile_options(mytarget)
```

#### `enable_autoformatter(TARGET)`

**Description**: Integrates clang-format for consistent code formatting.  
**Type**: Function  
**Arguments**:  
- `TARGET`: CMake target name  

**Actions**:  
- Downloads and copies `.clang-format` to project directory  
- Adds format file to target sources (visible in IDE)  
- In Visual Studio: Use Alt+K+F or enable "Format on Save"  

```cmake
enable_autoformatter(mytarget)
```

#### `enable_linter(TARGET)`

**Description**: Integrates clang-tidy static analysis.  
**Type**: Function  
**Platform**: MSVC integration only  
**Arguments**:  
- `TARGET`: CMake target name  

**Actions**:  
- Downloads and copies `.clang-tidy` to project directory  
- Enables clang-tidy in Visual Studio project settings  
- **Note**: Consider installing newer clang-tidy version than MSVC default  

```cmake
enable_linter(mytarget)
```

### High-Level Target Creation

#### `make_static_library(TARGET [DEPS dependencies...] [ENABLE_LINTER])`

**Description**: Creates a static library target with all cpp-init best practices applied automatically.  
**Type**: Macro  
**Arguments**:  
- `TARGET`: Library target name  
- `DEPS` (optional): List of dependencies to link publicly  
- `ENABLE_LINTER` (optional): Enable clang-tidy analysis  

**Automatic Actions**:  
- ✅ Globs headers and sources (`glob_headers_and_sources`)  
- ✅ Creates static library target  
- ✅ Links public include directory (`include/` → PUBLIC)  
- ✅ Links private include directory (`private_include/` → PRIVATE)  
- ✅ Applies compiler options (`apply_compile_options`)  
- ✅ Enables autoformatting (`enable_autoformatter`)  
- ✅ Links dependencies (if specified)  
- ✅ Enables linting (if `ENABLE_LINTER` specified)  

```cmake
make_static_library(MyLib 
    DEPS nlohmann_json::nlohmann_json fmt::fmt
    ENABLE_LINTER
)
```

#### `make_executable(TARGET [DEPS dependencies...] [ENABLE_LINTER])`

**Description**: Creates an executable target with all cpp-init best practices applied automatically.  
**Type**: Macro  
**Arguments**:  
- `TARGET`: Executable target name  
- `DEPS` (optional): List of dependencies to link  
- `ENABLE_LINTER` (optional): Enable clang-tidy analysis  

**Automatic Actions**: Same as `make_static_library` but creates executable instead  

```cmake
make_executable(MyApp 
    DEPS MyLib Catch2::Catch2WithMain
    ENABLE_LINTER
)
```

### Utility Macros

#### `link_public_header_folder(TARGET)`

**Description**: Links `include/` directory as PUBLIC if it exists.  
**Type**: Macro  

#### `link_private_header_folder(TARGET)`

**Description**: Links `private_include/` directory as PRIVATE if it exists.  
**Type**: Macro

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

## Contributing

Contributions are welcome! Here's how you can help:

### Reporting Issues
- Use the [GitHub issue tracker](https://github.com/nerudaj/cpp-init/issues) 
- Include your system information (Windows version, CMake version, etc.)
- Provide a minimal reproduction case

### Contributing Code
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes with the integration test  
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Platform Support
Currently optimized for **Windows/MSVC**. PRs welcome for:
- 🐧 Linux/GCC support
- 🍎 macOS/Clang support  
- 🔧 Other build systems

### Testing Changes
```bash
# Run integration tests
cd integration_test
cmake -B build -S .
cmake --build build
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Components
- **CPM.cmake**: Used for package management
- **clang-format**: Code formatting
- **clang-tidy**: Static analysis

---

**Made with ❤️ for the C++ community**

If cpp-init helped you kickstart your project, consider giving it a ⭐!