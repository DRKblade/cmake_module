# Add shared library for core functionalities {{{
  add_library(${PROJECT_NAME} SHARED ${SOURCES})
  list(APPEND targets ${PROJECT_NAME})
  target_include_directories(${PROJECT_NAME} PUBLIC ${INCLUDE_DIRS})

  set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER "${PUBLIC_HEADERS}")
  install(TARGETS ${PROJECT_NAME}
          LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})
# }}}

# Add the build result of the shared library to be used by the executable and external tests {{{
  add_library(${PROJECT_NAME}_physical SHARED IMPORTED)
  target_include_directories(${PROJECT_NAME}_physical INTERFACE ${PUBLIC_HEADERS_DIR})
  add_dependencies(${PROJECT_NAME}_physical ${PROJECT_NAME})
  set_property(TARGET ${PROJECT_NAME}_physical PROPERTY
               IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/bin/lib${PROJECT_NAME}.so)
# }}}

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
endif()

set_target_properties(${targets}
  PROPERTIES VERSION ${PROJECT_VERSION}
             RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
             LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

message("log level ${LOG_LEVEL}")
if(LOG_LEVEL GREATER -2)
  set(LG_ERR ON)
  if(LOG_LEVEL GREATER -1)
    set(LG_WARN true)
    if(LOG_LEVEL GREATER 0)
      set(LG_INFO true)
      if (LOG_LEVEL GREATER 1)
        set(LG_DBUG true)
message("reached ${LOG_LEVEL} ${LG_DBUG}")
      endif()
    endif()
  endif()
endif()

if(PLATFORM STREQUAL "Linux")
  set(PLATFORM_LINUX ON)
endif()
