configure_file(${CMAKE_CURRENT_LIST_DIR}/googletest.in
               ${CMAKE_BINARY_DIR}/googletest-download/CMakeLists.txt)

# Download and unpack googletest at configure time
function(setup_googletest)
  execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
                  RESULT_VARIABLE result
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/googletest-download)
  if(result)
    message(FATAL_ERROR "CMake step for googletest failed: ${result}")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} --build .
                  RESULT_VARIABLE result
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/googletest-download)
  if(result)
    message(FATAL_ERROR "Build step for googletest failed: ${result}")
  endif()

  # Add googletest directly to our build. This defines
  # the gtest, gtest_main, gmock and gmock_main targets.
  add_subdirectory(${CMAKE_BINARY_DIR}/googletest-src
                   ${CMAKE_BINARY_DIR}/googletest-build
                   EXCLUDE_FROM_ALL)
endfunction()

add_custom_target(${PROJECT_NAME}_tests COMMENT "Building all unit test")

## Utility functions to add unit tests
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

function(add_unit_tests test_root internal_tests external_tests copied_files)
  setup_googletest()

  foreach(test ${internal_tests})
    add_internal_test(${test_root} ${test})
  endforeach()
  foreach(test ${external_tests})
    add_external_test(${test_root} ${test})
  endforeach()
  foreach(file ${copied_files})
    configure_file(${test_root}/${file} ${CMAKE_BINARY_DIR}/test/${file} COPYONLY)
  endforeach()

  add_custom_target(check COMMAND GTEST_COLOR=1 ctest --output-on-failure
                          DEPENDS ${PROJECT_NAME}_tests)
endfunction()
