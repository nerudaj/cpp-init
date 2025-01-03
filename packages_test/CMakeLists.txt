cmake_minimum_required ( VERSION 3.26 )

include ( "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/get_cpp_init.cmake" )
bootstrap_cpm()

project ( packages-test )

cpm_add_base64()
cpm_add_catch2()
cpm_add_cxxopts()
cpm_add_dgmlib()
cpm_add_eigen()
cpm_add_entt()
cpm_add_fakeit()
cpm_add_fsmlib()
cpm_add_nlohmann_json()
cpm_add_sfml()
cpm_add_sfml3()

make_executable (
    ${PROJECT_NAME}
)
