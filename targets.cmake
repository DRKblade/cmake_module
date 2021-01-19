function(auto_targets project_name include_dirs header_dir source_files header_files executable_files)
  ## Add shared library for core functionalities
  add_library(${project_name} SHARED ${source_files})
  list(APPEND targets ${project_name})
  target_include_directories(${project_name} PUBLIC ${include_dirs})

  set_target_properties(${project_name} PROPERTIES PUBLIC_HEADER "${header_files}")
  install(TARGETS ${project_name}
          LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${project_name})

  ## Add the build result of the shared library to be used by the executable and external tests
  add_library(${project_name}_physical SHARED IMPORTED)
  target_include_directories(${project_name}_physical INTERFACE ${header_dir})
  add_dependencies(${project_name}_physical ${project_name})
  set_property(TARGET ${project_name}_physical PROPERTY
               IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/bin/lib${project_name}.so)

  ## Add executable to provide a command-line interface
  if(NOT executable_files STREQUAL "")
    add_executable(${project_name}_exec ${executable_files})
    list(APPEND targets ${project_name}_exec)
    target_link_libraries(${project_name}_exec ${project_name}_physical)
    target_include_directories(${project_name}_exec PUBLIC ${include_dirs})

    set_target_properties(${project_name}_exec PROPERTIES OUTPUT_NAME ${project_name})
    install(TARGETS ${project_name}_exec
            DESTINATION ${CMAKE_INSTALL_BINDIR}
            COMPONENT runtime)
  endif()

  set_target_properties(${targets}
    PROPERTIES VERSION ${PROJECT_VERSION}
               RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
               LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
endfunction()
