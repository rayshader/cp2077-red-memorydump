cmake_minimum_required(VERSION 3.27)
project(RedMemoryDump VERSION 0.4.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

configure_file(src/Config.h.in Config/Config.h)

set(INC_FILES
        src/MemoryDump.h

        src/Data/MemoryCurveDataFloat.h
        src/Data/MemoryTarget.h
        src/Data/MemoryTargetAddress.h
        src/Data/MemoryTargetWeakHandle.h
        src/Data/MemoryFrame.h
        src/Data/MemoryProperty.h
)

set(SRC_FILES
        src/main.cpp

        src/MemoryDump.cpp

        src/Data/MemoryCurveDataFloat.cpp
        src/Data/MemoryTarget.cpp
        src/Data/MemoryTargetAddress.cpp
        src/Data/MemoryTargetWeakHandle.cpp
        src/Data/MemoryFrame.cpp
        src/Data/MemoryProperty.cpp
)

source_group(include FILES INC_FILES)
source_group(source FILES SRC_FILES)

add_library(RedMemoryDump SHARED
        ${INC_FILES}
        ${SRC_FILES}
)

target_include_directories(RedMemoryDump PRIVATE
        src/
        src/Data/
)

# Include configured files
target_include_directories(RedMemoryDump PUBLIC "${PROJECT_BINARY_DIR}/Config")

# Exclude unused Windows headers
add_compile_definitions(WIN32_LEAN_AND_MEAN)

## Library RED4ext.SDK
option(RED4EXT_HEADER_ONLY "" ON)
add_subdirectory(deps/RED4ext.SDK)
set_target_properties(RED4ext.SDK PROPERTIES FOLDER "Dependencies")
mark_as_advanced(RED4EXT_BUILD_EXAMPLES RED4EXT_HEADER_ONLY)
##

## Library RedLib
add_compile_definitions(NOMINMAX)
add_subdirectory(deps/RedLib)
set_target_properties(RedLib PROPERTIES FOLDER "Dependencies")
##

target_link_libraries(RedMemoryDump PRIVATE
        RED4ext::SDK
        RedLib
)

## Debug mode: install scripts and plugin in game folder.
## Release mode: create archive with bundled scripts and plugin.
add_custom_command(
        TARGET RedMemoryDump
        POST_BUILD
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "$<$<CONFIG:Debug>:Install scripts with red-cli>" "$<$<CONFIG:Release>:Build archive with red-cli>"
        COMMAND "$<$<CONFIG:Debug>:red-cli;install>" "$<$<CONFIG:Release>:red-cli;pack>"
        COMMAND_EXPAND_LISTS
)