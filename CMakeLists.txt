cmake_minimum_required(VERSION 3.14)
project(toml_parser C)

macro(add_sources)
  file(RELATIVE_PATH
       _relPath
       "${CMAKE_SOURCE_DIR}"
       "${CMAKE_CURRENT_SOURCE_DIR}")
  foreach(_src ${ARGN})
    if(_relPath)
      file(TO_NATIVE_PATH "${_relPath}/${_src}" _nativePath)
    else()
      file(TO_NATIVE_PATH ${_src} _nativePath)
    endif()
    set_property(TARGET "toml_parser" APPEND PROPERTY SRC_LIST ${_nativePath})
  endforeach()
endmacro()

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

bison_target(TOMLParser src/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
flex_target(TOMLScanner src/lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.c)
add_flex_bison_dependency(TOMLScanner TOMLParser)

set(EXEC_NAME "toml_parser")
add_executable(${EXEC_NAME} "")
set_property(TARGET ${EXEC_NAME} PROPERTY C_STANDARD 99)

target_compile_options(${EXEC_NAME} PRIVATE -Wall -Wextra -pedantic -Werror)

add_subdirectory(src)
get_property(SRC_LIST TARGET ${EXEC_NAME} PROPERTY SRC_LIST)
target_sources(${EXEC_NAME}
	       PRIVATE
	       ${SRC_LIST}
	       ${BISON_TOMLParser_OUTPUTS}
	       ${FLEX_TOMLScanner_OUTPUTS})

target_include_directories(${EXEC_NAME} PRIVATE src)
target_include_directories(${EXEC_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
