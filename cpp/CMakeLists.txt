cmake_minimum_required(VERSION 3.20)

project(TreonCpp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Library
add_library(treon_core
    src/JSONNode.cpp
    src/JSONParser.cpp
)

target_include_directories(treon_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(treon_core PUBLIC cxx_std_20)

enable_testing()
add_subdirectory(tests)

