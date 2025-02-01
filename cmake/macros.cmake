macro ( link_public_header_folder TARGET )
    if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories( ${TARGET} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" )
    endif ()
endmacro ()

macro ( link_private_header_folder TARGET )
    if ( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/private_include")
        target_include_directories( ${TARGET} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/private_include" )
    endif ()
endmacro ()

macro ( make_static_library TARGET )
    set( options )
    set( multiValueArgs DEPS )

    cmake_parse_arguments ( CIMSL "${options}" "" "${multiValueArgs}" ${ARGN} )

    glob_headers_and_sources ( HEADERS SOURCES )

    add_library( ${TARGET} STATIC ${HEADERS} ${SOURCES} )

    link_public_header_folder ( ${TARGET} )
    link_private_header_folder ( ${TARGET} )

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

    add_executable( ${TARGET} ${HEADERS} ${SOURCES} )

    link_public_header_folder ( ${TARGET} )
    link_private_header_folder ( ${TARGET} )

    if ( CIME_DEPS )
        target_link_libraries ( ${TARGET} PUBLIC ${CIME_DEPS} )
    endif ()

    enable_autoformatter ( ${TARGET} )
    apply_compile_options ( ${TARGET} )
endmacro()

macro ( cpm_add_base64 )
    CPMAddPackage("gh:tobiaslocker/base64#master")
endmacro ()

macro ( cpm_add_catch2 )
    CPMAddPackage("gh:catchorg/Catch2#v3.7.1")
endmacro ()

macro ( cpm_add_cxxopts )
    CPMAddPackage("gh:nlohmann/json#v3.11.3")
endmacro ()

macro ( cpm_add_dgmlib )
    CPMAddPackage("gh:nerudaj/dgm-lib#v2.3.1")
endmacro ()

macro ( cpm_add_eigen )
    CPMAddPackage("gl:libeigen/eigen#master")
endmacro ()

macro ( cpm_add_entt )
    CPMAddPackage("gh:skypjack/entt#v3.14.0")
endmacro ()

macro ( cpm_add_fakeit )
    CPMAddPackage("gh:eranpeer/FakeIt#2.4.1")
endmacro ()

macro ( cpm_add_fsmlib )
    CPMAddPackage("gh:nerudaj/fsm-lib#v2.1.0")
endmacro ()

macro ( cpm_add_nlohmann_json )
    CPMAddPackage("gh:SFML/SFML#3.0.0")
endmacro ()

macro ( cpm_add_sfml )
    CPMAddPackage("gh:SFML/SFML#2.6.1")
endmacro ()

macro ( cpm_add_sfml3 )
    CPMAddPackage("gh:SFML/SFML#3.0.0")
endmacro ()
