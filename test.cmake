enable_testing()

# Utility functions to add unit tests {{{
  function(setup_unit_test root_dir source_file output_name)
    string(REPLACE "/" "_" testname ${source_file})
    set(name "test.${testname}")
    set(${output_name} ${name} PARENT_SCOPE)
    add_executable(${name} ${root_dir}/${source_file}.cpp)
    add_dependencies(${PROJECT_NAME}_tests ${name})
    set_target_properties(${name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test)
    target_link_libraries(${name} ${PROJECT_NAME} gmock_main)
    target_compile_options(${name} PRIVATE -fprofile-arcs -ftest-coverage --coverage)
    target_link_options(${name} PRIVATE -lgcov --coverage)
    add_test(NAME ${name} COMMAND ./${name} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test)
  endfunction()

  # Add internal unit tests. Public and private headers are visible to them
  function(add_internal_test root_dir source_file)
    setup_unit_test(${root_dir} ${source_file} name)
    target_include_directories(${name} PUBLIC "${PUBLIC_HEADERS_DIR}" "${INCLUDE_DIRS}")
  endfunction()

  # Add external unit tests. Only the public headers are visible to them
  function(add_external_test root_dir source_file)
    setup_unit_test(${root_dir} ${source_file} name)
    target_include_directories(${name} PUBLIC "${PUBLIC_HEADERS_DIR}" "${CMAKE_BINARY_DIR}/include")
  endfunction()
# }}}

# Add unit tests {{{
  add_custom_target(${PROJECT_NAME}_tests COMMENT "Building all unit test")
  add_custom_target(check
    COMMAND GTEST_COLOR=1 ctest --output-on-failure
    DEPENDS ${PROJECT_NAME}_tests
  )
  # Update googletest submodule
  execute_process(
    COMMAND git submodule update --init -- ${LIBRARY_DIR}/googletest
    RESULT_VARIABLE result
  )
  if(result)
    message(FATAL_ERROR "Googletest submodule not found at ${LIBRARY_DIR}/googletest")
  endif()
  set(INSTALL_GTEST OFF)
  add_subdirectory(${CMAKE_SOURCE_DIR}/lib/googletest EXCLUDE_FROM_ALL)

  # Add unit tests and copied files
  foreach(test ${INTERNAL_TESTS})
    add_internal_test(${TEST_DIR} ${test})
  endforeach()
  foreach(test ${EXTERNAL_TESTS})
    add_external_test(${TEST_DIR} ${test})
  endforeach()
  foreach(file ${COPIED_FILES})
    configure_file(${TEST_DIR}/samples/${file} ${CMAKE_BINARY_DIR}/test/${file} COPYONLY)
  endforeach()
# }}}

# Generate code coverage report
if(GEN_COVERAGE)
  add_custom_target(cov_init
    COMMAND mkdir -p coverage/lcov coverage/report coverage/codecov
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )
  add_custom_target(lcov
    COMMAND lcov -c -d CMakeFiles -o coverage/lcov/main_coverage.info --include "${SRC_DIR}/\\*" --include "${PUBLIC_HEADERS_DIR}/\\*" && genhtml coverage/lcov/main_coverage.info --output-directory coverage/report
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )
  add_custom_target(codecov_upload
    COMMAND curl -s https://codecov.io/bash > codecov.sh
    COMMAND bash codecov.sh
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/coverage/codecov
  )
endif()
