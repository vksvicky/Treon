cmake_minimum_required(VERSION 3.20)

project(TreonCpp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Quick Widgets)

# Enable Qt MOC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Core library
add_library(treon_core
    src/JSONNode.cpp
    src/JSONParser.cpp
    src/JSONViewModel.cpp
    src/ErrorHandler.cpp
    src/DirectoryManager.cpp
    src/FileInfo.cpp
    src/FileManager.cpp
)

target_include_directories(treon_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(treon_core
    PUBLIC
        Qt6::Core
)

target_compile_features(treon_core PUBLIC cxx_std_20)

# Main application
add_executable(treon_app
    src/main.cpp
    src/Application.cpp
    qml/main.qml
    qml/JSONViewer.qml
    qml/TwoPaneLayout.qml
    resources/resources.qrc
)

target_link_libraries(treon_app
    PRIVATE
        treon_core
        Qt6::Core
        Qt6::Quick
        Qt6::Widgets
)

# Tests
enable_testing()
add_subdirectory(tests)

