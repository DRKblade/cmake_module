# Utility functions to add unit tests {{{
  function(setup_unit_test root_dir source_file output_name)
    string(REPLACE "/" "_" testname ${source_file})
    set(name "test.${testname}")
    set(${output_name} ${name} PARENT_SCOPE)
    add_executable(${name} ${root_dir}/${source_file}.cpp)
    add_test(NAME ${name} COMMAND ${name})
    add_dependencies(${PROJECT_NAME}_tests ${name})
    set_target_properties(${name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test)
  endfunction()

  # Add internal unit tests. Public and private headers are visible to them
  function(add_internal_test root_dir source_file)
    setup_unit_test(${root_dir} ${source_file} name)

    # Link against gmock (this automatically links against gtest)
    target_link_libraries(${name} ${PROJECT_NAME} gmock_main)
  endfunction()

  # Add external unit tests. Only the public headers are visible to them
  function(add_external_test root_dir source_file)
    setup_unit_test(${root_dir} ${source_file} name)
    target_link_libraries(${name} ${PROJECT_NAME}_physical gmock_main)
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
    configure_file(${TEST_DIR}/${file} ${CMAKE_BINARY_DIR}/test/${file} COPYONLY)
  endforeach()
# }}}

# Generate code coverage report
if(GEN_COVERAGE)
  target_compile_options(${PROJECT_NAME} PRIVATE -fprofile-arcs -ftest-coverage --coverage)
  target_link_options(${PROJECT_NAME} PRIVATE -lgcov --coverage)

  add_custom_target(cov_init
    COMMAND mkdir -p coverage/lcov coverage/report
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )
  add_custom_target(lcov
    COMMAND lcov -c -d CMakeFiles/ -o coverage/lcov/main_coverage.info --include "${CMAKE_SOURCE_DIR}/\\*" &&
            genhtml coverage/lcov/main_coverage.info --output-directory coverage/report
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )
endif()
