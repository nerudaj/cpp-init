cmake_minimum_required ( VERSION 3.26 )

CPMAddPackage( "gh:nlohmann/json@3.11.2" )

set ( TARGET mylib )

make_static_library ( ${TARGET} DEPS nlohmann::json )
