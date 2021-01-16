Example configuration for file_list.cmake
```
# paths to various directories
get_filename_component(GENERATED_HEADERS_DIR ${CMAKE_BINARY_DIR}/generated-headers ABSOLUTE)
get_filename_component(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include ABSOLUTE)
get_filename_component(PRIVATE_HEADERS_DIR ${CMAKE_SOURCE_DIR}/private-headers ABSOLUTE)
get_filename_component(SRC_DIR ${CMAKE_SOURCE_DIR}/src ABSOLUTE)
get_filename_component(TEST_DIR ${CMAKE_SOURCE_DIR}/test ABSOLUTE)
set(HEADER_DIRS ${INCLUDE_DIR} ${PRIVATE_HEADERS_DIR} ${GENERATED_HEADERS_DIR})

# configure files {{{
  if(PLATFORM EQUAL "Linux")
    add_compile_definitions(PLATFORM_LINUX)
  endif()

  configure_file(${PRIVATE_HEADERS_DIR}/common.hpp.in 
    ${GENERATED_HEADERS_DIR}/common.hpp
    ESCAPE_QUOTES)

  unset(DEBUG_SCOPES CACHE)
# }}}

# public headers
set(HEADERS
  ${INCLUDE_DIR}/_header_.hpp
)

# source files
set(SOURCES
  ${SRC_DIR}/_src_.cpp
)

set(INTERNAL_TESTS _test1_)
set(EXTERNAL_TESTS _test2_)
set(TEST_FILES _test_file_)
```
