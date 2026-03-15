cmake_minimum_required(VERSION 3.0)
project(facile VERSION 0.9.0 LANGUAGES C)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

flex_target(FACILE_SCANNER facile.lex "${CMAKE_CURRENT_BINARY_DIR}/facile.lex.c")
bison_target(FACILE_PARSER facile.y "${CMAKE_CURRENT_BINARY_DIR}/facile.y.c")

add_executable(facile
  ${FLEX_FACILE_SCANNER_OUTPUTS}
  ${BISON_FACILE_PARSER_OUTPUTS}
)

target_link_libraries(facile fl)

# Ajout GLib
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB2 REQUIRED glib-2.0)
include_directories(${GLIB2_INCLUDE_DIRS})
link_directories(${GLIB2_LIBRARY_DIRS})
add_definitions(${GLIB2_CFLAGS_OTHER})
target_link_libraries(facile ${GLIB2_LIBRARIES})
