cmake_minimum_required(VERSION 3.20)

project(TreonCpp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Quick Widgets Test)

# Enable Qt MOC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Automatically discover source files
file(GLOB_RECURSE CORE_HEADERS "include/treon/*.hpp")
file(GLOB_RECURSE CORE_SOURCES "src/*.cpp")
# Remove main.cpp and Application.cpp from core sources as they belong to the app
list(REMOVE_ITEM CORE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
list(REMOVE_ITEM CORE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/Application.cpp")
# Remove Application.hpp from core headers as it belongs to the app
list(REMOVE_ITEM CORE_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/treon/Application.hpp")

# Core library
add_library(treon_core
    ${CORE_HEADERS}
    ${CORE_SOURCES}
)

target_include_directories(treon_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(treon_core
    PUBLIC
        Qt6::Core
        Qt6::Widgets
)

target_compile_features(treon_core PUBLIC cxx_std_20)

# Automatically discover application files
file(GLOB_RECURSE APP_HEADERS "include/treon/Application.hpp")
file(GLOB_RECURSE APP_SOURCES "src/main.cpp" "src/Application.cpp")
file(GLOB_RECURSE QML_FILES "qml/*.qml")
file(GLOB_RECURSE RESOURCE_FILES "resources/*.qrc")

# Main application
add_executable(treon_app
    ${APP_HEADERS}
    ${APP_SOURCES}
    ${QML_FILES}
    ${RESOURCE_FILES}
)

target_link_libraries(treon_app
    PRIVATE
        treon_core
        Qt6::Core
        Qt6::Quick
        Qt6::Widgets
)

# Tests (temporarily disabled)
# enable_testing()
# add_subdirectory(tests)

