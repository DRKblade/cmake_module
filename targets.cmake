function(auto_targets project_name include_dirs header_dir source_files header_files executable_files)
  add_library(${project_name} SHARED ${source_files})
  target_include_directories(${project_name} PUBLIC ${include_dirs})

  set_target_properties(${project_name} PROPERTIES PUBLIC_HEADER "${header_files}")
  install(TARGETS ${project_name}
          LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${project_name})

  add_library(${project_name}_physical SHARED IMPORTED)
  target_include_directories(${project_name}_physical INTERFACE ${header_dir})
  set_property(TARGET ${project_name}_physical PROPERTY
               IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/bin/lib${project_name}.so)

  add_executable(${project_name}_exec ${executable_files})
  target_link_libraries(${project_name}_exec ${project_name}_physical)
  target_include_directories(${project_name}_exec PUBLIC ${include_dirs})

  set_target_properties(${project_name}_exec PROPERTIES OUTPUT_NAME ${project_name})
  install(TARGETS ${project_name}_exec
          DESTINATION ${CMAKE_INSTALL_BINDIR}
          COMPONENT runtime)

  set_target_properties(${project_name} ${project_name}_exec
    PROPERTIES VERSION ${PROJECT_VERSION}
               RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
               LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  )
endfunction()
