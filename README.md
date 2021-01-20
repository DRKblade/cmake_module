Example configuration for file_list.cmake
```
# paths to various directories
get_filename_component(GENERATED_HEADERS_DIR ${CMAKE_BINARY_DIR}/generated-headers ABSOLUTE)
get_filename_component(PUBLIC_HEADERS_DIR    ${CMAKE_CURRENT_LIST_DIR}/include ABSOLUTE)
get_filename_component(PRIVATE_HEADERS_DIR   ${CMAKE_CURRENT_LIST_DIR}/private-headers ABSOLUTE)
get_filename_component(SRC_DIR               ${CMAKE_CURRENT_LIST_DIR}/src ABSOLUTE)
get_filename_component(TEST_DIR              ${CMAKE_CURRENT_LIST_DIR}/test ABSOLUTE)
get_filename_component(LIBRARY_DIR           ${CMAKE_CURRENT_LIST_DIR}/lib ABSOLUTE)
list(APPEND INCLUDE_DIRS ${PUBLIC_HEADERS_DIR} ${PRIVATE_HEADERS_DIR} ${GENERATED_HEADERS_DIR})

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
set(PUBLIC_HEADERS
  ${PUBLIC_HEADERS_DIR}/_header_.hpp
)

# source files
set(SOURCES
  ${SRC_DIR}/_source_.cpp
)

set(INTERNAL_TESTS _test_)
set(EXTERNAL_TESTS _test_)
set(COPIED_FILES _file.txt_)
```
