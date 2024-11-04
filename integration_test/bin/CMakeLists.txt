cmake_minimum_required ( VERSION 3.26 )

set ( TARGET mybin )

make_executable ( ${TARGET} DEPS mylib )

add_test (
    NAME ${TARGET}
    COMMAND ${TARGET}
)
