Example configuration for file_list.cmake
```
# paths to various directories
get_filename_component(generated_headers_dir ${CMAKE_BINARY_DIR}/generated-headers ABSOLUTE)
get_filename_component(include_dir ${CMAKE_SOURCE_DIR}/include ABSOLUTE)
get_filename_component(private_headers_dir ${CMAKE_SOURCE_DIR}/private-headers ABSOLUTE)
get_filename_component(src_dir ${CMAKE_SOURCE_DIR}/src ABSOLUTE)
get_filename_component(test_dir ${CMAKE_SOURCE_DIR}/test ABSOLUTE)
set(header_dirs ${include_dir} ${private_headers_dir} ${generated_headers_dir})

# configure files {{{
  if(PLATFORM EQUAL "Linux")
    add_compile_definitions(PLATFORM_LINUX)
  endif()

  configure_file(${private_headers_dir}/common.hpp.in 
    ${generated_headers_dir}/common.hpp
    ESCAPE_QUOTES)

  unset(DEBUG_SCOPES CACHE)
# }}}

# public headers
set(HEADERS
  ${include_dir}/???.hpp
)

# source files
set(SOURCES
  ${src_dir}/???.cpp
)

if(BUILD_TESTS)
  enable_testing()
  include(cmake/test)

  add_unit_test(???)
  add_lib_test(???)
endif()
```
