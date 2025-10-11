# Tests CMakeLists.txt - Refactored Structure

# Find Qt6 Test component
find_package(Qt6 REQUIRED COMPONENTS Test)

# =============================================================================
# COMMON TEST UTILITIES
# =============================================================================

# Common test helpers
set(COMMON_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/common/test_helpers.cpp
)

set(COMMON_HEADERS
    common/test_helpers.hpp
)

# =============================================================================
# UNIT TESTS
# =============================================================================

# Discover unit test sources
file(GLOB UNIT_TEST_SOURCES "unit/*.cpp")

# Create individual unit test executables
foreach(UNIT_TEST_SOURCE ${UNIT_TEST_SOURCES})
    get_filename_component(TEST_NAME ${UNIT_TEST_SOURCE} NAME_WE)
    
    add_executable(${TEST_NAME} 
        ${UNIT_TEST_SOURCE}
        ${COMMON_SOURCES}
    )
    
    target_link_libraries(${TEST_NAME}
        PRIVATE
            Qt6::Test
            Qt6::Core
            Qt6::Widgets
            Qt6::Quick
            Qt6::QuickDialogs2
            treon_app_lib
    )
    
    target_include_directories(${TEST_NAME} PRIVATE 
        ${CMAKE_SOURCE_DIR}/include
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/common
    )
    
    set_target_properties(${TEST_NAME} PROPERTIES
        AUTOMOC ON
        AUTORCC ON
        AUTOUIC ON
    )
    
    # Add to CTest
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
    set_tests_properties(${TEST_NAME} PROPERTIES
        TIMEOUT 300
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endforeach()

# =============================================================================
# BENCHMARK TESTS
# =============================================================================

# JSON Benchmark sources
set(JSON_BENCHMARK_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/benchmark/json/json_benchmark_suite.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/benchmark/json/json_data_generator.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/benchmark/json/json_test_config.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/benchmark/json/run_json_benchmark.cpp
    ${COMMON_SOURCES}
)

set(JSON_BENCHMARK_HEADERS
    benchmark/json/json_benchmark_suite.hpp
    benchmark/json/json_data_generator.hpp
    benchmark/json/json_test_config.hpp
)

# Create JSON benchmark runner
add_executable(json_benchmark_runner ${JSON_BENCHMARK_SOURCES})

target_link_libraries(json_benchmark_runner
    PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
        treon_app_lib
)

target_include_directories(json_benchmark_runner PRIVATE 
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/common
)

set_target_properties(json_benchmark_runner PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    AUTOUIC ON
)

# Add JSON benchmark to CTest
add_test(NAME json_benchmark COMMAND json_benchmark_runner)
set_tests_properties(json_benchmark PROPERTIES
    TIMEOUT 1800  # 30 minutes for large file tests
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

# Integration test sources (BDD-style)
file(GLOB INTEGRATION_TEST_SOURCES "integration/features/steps/*.cpp")

# Create integration test executable
if(INTEGRATION_TEST_SOURCES)
    add_executable(treon_integration_tests 
        ${INTEGRATION_TEST_SOURCES}
    )
    
    target_link_libraries(treon_integration_tests
        PRIVATE
            Qt6::Test
            Qt6::Core
            Qt6::Widgets
            Qt6::Quick
            Qt6::QuickDialogs2
            treon_app_lib
    )
    
    target_include_directories(treon_integration_tests PRIVATE 
        ${CMAKE_SOURCE_DIR}/include
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/common
    )
    
    set_target_properties(treon_integration_tests PROPERTIES
        AUTOMOC ON
        AUTORCC ON
        AUTOUIC ON
    )
    
    # Add to CTest
    add_test(NAME integration_tests COMMAND treon_integration_tests)
    set_tests_properties(integration_tests PROPERTIES
        TIMEOUT 600
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

# =============================================================================
# COVERAGE REPORTS
# =============================================================================

# Add custom target for running tests with coverage
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_program(GCOV_PATH gcov)
    find_program(LCOV_PATH lcov)
    find_program(GENHTML_PATH genhtml)
    
    if(GCOV_PATH AND LCOV_PATH AND GENHTML_PATH)
        add_custom_target(test_coverage
            COMMAND ${CMAKE_CTEST_COMMAND} --verbose
            COMMAND ${LCOV_PATH} --directory . --capture --output-file coverage.info
            COMMAND ${LCOV_PATH} --remove coverage.info '/usr/*' --output-file coverage.info.cleaned
            COMMAND ${GENHTML_PATH} -o coverage coverage.info.cleaned
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage report generated in coverage/index.html"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS treon_unit_tests json_benchmark_runner treon_integration_tests
            COMMENT "Running all tests and generating coverage report"
        )
    endif()
endif()

# =============================================================================
# DEBUG OUTPUT
# =============================================================================

message(STATUS "=== Test Structure ===")
message(STATUS "Unit test sources: ${UNIT_TEST_SOURCES}")
message(STATUS "Integration test sources: ${INTEGRATION_TEST_SOURCES}")
message(STATUS "JSON benchmark sources: ${JSON_BENCHMARK_SOURCES}")
message(STATUS "Common sources: ${COMMON_SOURCES}")
message(STATUS "======================")