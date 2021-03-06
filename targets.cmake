function(add_shared_lib name sources include_dirs public_headers header_install_path)
  add_library(${name} SHARED ${sources})
  list(APPEND targets ${name})
  target_include_directories(${name} PRIVATE ${include_dirs})
  set_target_properties(${name} PROPERTIES PUBLIC_HEADER "${public_headers}")
  install(TARGETS ${name}
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/${header_install_path})

  # Put all header files in one place to be used by external tests
  set(assembly_path ${CMAKE_BINARY_DIR}/include/${header_install_path})
  file(MAKE_DIRECTORY ${assembly_path})
  foreach(header ${public_headers})
    get_filename_component(header_name ${header} NAME)
    configure_file(${header} ${assembly_path}/${header_name} COPYONLY)
  endforeach()

  if(GEN_COVERAGE)
    target_compile_options(${name} PRIVATE -fprofile-arcs -ftest-coverage --coverage)
    target_link_options(${name} PRIVATE -lgcov --coverage)
  endif()

  set_target_properties(${name} PROPERTIES
      VERSION ${PROJECT_VERSION} LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
endfunction()

## Add executable to provide a command-line interface
if(EXECUTABLES)
  add_executable(${PROJECT_NAME}_exec ${EXECUTABLES})
  list(APPEND targets ${PROJECT_NAME}_exec)
  target_link_libraries(${PROJECT_NAME}_exec ${PROJECT_NAME}_physical)
  target_include_directories(${PROJECT_NAME}_exec PUBLIC ${PUBLIC_HEADERS_DIR})

  set_target_properties(${PROJECT_NAME}_exec PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
  install(TARGETS ${PROJECT_NAME}_exec
          DESTINATION ${CMAKE_INSTALL_BINDIR}
          COMPONENT runtime)

  set_target_properties(${PROJECT_NAME}_exec PROPERTIES
      VERSION ${PROJECT_VERSION} RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
endif()

