cmake_minimum_required(VERSION 3.20)
project(TreonCpp VERSION 1.0.0 LANGUAGES CXX)

# Set C++20 standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find Qt6 components
find_package(Qt6 REQUIRED COMPONENTS 
    Core 
    Quick 
    Widgets 
    Test 
    QuickDialogs2
    Sql
    Network
    LinguistTools
)

# Enable Qt's meta-object compiler
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Automatically discover source files
file(GLOB_RECURSE CORE_HEADERS "include/*.hpp")
file(GLOB_RECURSE CORE_SOURCES "src/*.cpp")
# Remove main.cpp, Application.cpp, and AboutWindow.cpp from core sources as they belong to the app
list(REMOVE_ITEM CORE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
list(REMOVE_ITEM CORE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/Application.cpp")
list(REMOVE_ITEM CORE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/AboutWindow.cpp")
# Remove Application.hpp and AboutWindow.hpp from core headers as they belong to the app
list(REMOVE_ITEM CORE_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/Application.hpp")
list(REMOVE_ITEM CORE_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/AboutWindow.hpp")

# Core library
add_library(treon_core
    ${CORE_HEADERS}
    ${CORE_SOURCES}
)

target_include_directories(treon_core PUBLIC include)

target_link_libraries(treon_core 
    PUBLIC 
        Qt6::Core 
        Qt6::Widgets
        Qt6::Sql
        Qt6::Network
)

# Application library (for sharing between main app and tests)
add_library(treon_app_lib
    include/Application.hpp
    include/AboutWindow.hpp
    src/Application.cpp
    src/AboutWindow.cpp
)

target_include_directories(treon_app_lib PUBLIC include)

target_link_libraries(treon_app_lib
    PUBLIC
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
        Qt6::QuickDialogs2
        treon_core
)

# Automatically discover application files
file(GLOB_RECURSE QML_FILES "qml/*.qml")
file(GLOB_RECURSE RESOURCE_FILES "resources/*.qrc")
file(GLOB_RECURSE ICON_FILES "resources/*.icns")
file(GLOB_RECURSE TS_FILES "translations/*.ts")

# Translation files
qt6_add_translations(Treon TS_FILES ${TS_FILES})

# Main application
add_executable(Treon
    src/main.cpp
    ${QML_FILES}
    ${RESOURCE_FILES}
    ${ICON_FILES}
)

target_include_directories(Treon PRIVATE include)

target_link_libraries(Treon
    PRIVATE
        treon_app_lib
        Qt6::Core
        Qt6::Quick
        Qt6::Widgets
        Qt6::QuickDialogs2
        Qt6::Sql
        Qt6::Network
)

# Tests - temporarily disabled due to MOC conflicts
# enable_testing()
# add_subdirectory(tests)

# Set application properties
set_target_properties(Treon PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_NAME "Treon"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0"
    MACOSX_BUNDLE_IDENTIFIER "club.cycleruncode.treon"
    MACOSX_BUNDLE_INFO_STRING "Treon - Your JSON, visual and alive."
    MACOSX_BUNDLE_COPYRIGHT "Copyright © 2025 CycleRunCode Club"
    MACOSX_BUNDLE_GUI_IDENTIFIER "club.cycleruncode.treon"
    MACOSX_BUNDLE_ICON_FILE "icon.icns"
)

# Copy icon to bundle
set_source_files_properties(resources/icon.png PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
set_source_files_properties(resources/icon.icns PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

# Include tests subdirectory
add_subdirectory(tests)