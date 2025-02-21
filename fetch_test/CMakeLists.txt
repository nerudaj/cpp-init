cmake_minimum_required ( VERSION 3.26 )

include ( "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/cpp-init.cmake" )

fetch_headeronly_dependency (
    JSON 
    URL "https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp"
)

fetch_prebuilt_dependency (
    DGM
    URL "https://github.com/nerudaj/fsm-lib/releases/download/v2.1.0/fsm-lib-v2.1.0-Windows-MSVC-x64.zip"
)

project ( demo LANGUAGES CXX )
