@echo off
setlocal enabledelayedexpansion

:: Ask for project name
set /p PROJECT_NAME=Enter project name: 

:: Ask whether to create a library target
set /p CREATE_LIB=Create a library target? (y/n): 

echo Creating project structure for "%PROJECT_NAME%"...

:: Create base folders
mkdir "cmake"
mkdir "bin"
mkdir "bin\include"
mkdir "bin\src"

:: Conditionally create library folders
if /i "%CREATE_LIB%"=="y" (
    mkdir "lib"
    mkdir "lib\include"
    mkdir "lib\src"
    mkdir "tests"
    mkdir "tests\include"
    mkdir "tests\src"
)

:: Download cpp-init.cmake into cmake folder
echo Downloading cpp-init.cmake...
powershell -Command ^
    "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/nerudaj/cpp-init/refs/heads/main/cmake/cpp-init.cmake', 'cmake\cpp-init.cmake')"


echo Creating top-level cmake lists

echo cmake_minimum_required ( VERSION 3.28 ) >CMakeLists.txt
echo include ( ${CMAKE_SOURCE_DIR}/cmake/cpp-init.cmake ) >>CMakeLists.txt
echo get_version_from_git(PROJECT_VERSION_VARIABLE GIT_PROJECT_VERSION FULL_VERSION_VARIABLE GIT_FULL_VERSION) >>CMakeLists.txt
echo project( %PROJECT_NAME% VERSION ${GIT_PROJECT_VERSION} LANGUAGES CXX )
echo add_subdirectory( bin ) >>CMakeLists.txt
if /i "%CREATE_LIB%"=="y" (
    echo add_subdirectory( lib ) >>CMakeLists.txt
    echo add_subdirectory( tests ) >>CMakeLists.txt
)

echo Creating bin CMakeLists.txt

echo cmake_minimum_required ( VERSION 3.28 ) >bin/CMakeLists.txt

if /i "%CREATE_LIB%"=="y" (
    echo make_executable( ${PROJECT_NAME} DEPS lib%PROJECT_NAME% ) >>bin/CMakeLists.txt
) else (
    echo make_executable( ${PROJECT_NAME} ) >>bin/CMakeLists.txt
)

echo int main() ^{ >>bin/src/Main.cpp
echo     return 0; >>bin/src/Main.cpp
echo ^} >>bin/src/Main.cpp

if /i "%CREATE_LIB%"=="y" (
    echo cmake_minimum_required ( VERSION 3.28 ) >lib/CMakeLists.txt
    echo make_static_library( ${PROJECT_NAME} ) >>lib/CMakeLists.txt

    echo cmake_minimum_required ( VERSION 3.28 ) >tests/CMakeLists.txt
    echo make_executable( ${PROJECT_NAME}_tests DEPS lib%PROJECT_NAME% ) >>tests/CMakeLists.txt
)

cmake -B _build .

pause
