# Tests CMakeLists.txt

# Find Qt6 Test component
find_package(Qt6 REQUIRED COMPONENTS Test)

# Automatically discover all C++ source files
file(GLOB ALL_CPP_SOURCES "*.cpp")

# Separate test files from benchmark runner files
set(TEST_SOURCES "")
set(BENCHMARK_SOURCES "")

foreach(SOURCE_FILE ${ALL_CPP_SOURCES})
    get_filename_component(FILENAME ${SOURCE_FILE} NAME)
    
    # Benchmark runner files (only the main runner)
    if(FILENAME MATCHES "^run_json_benchmark\\.cpp$")
        list(APPEND BENCHMARK_SOURCES ${SOURCE_FILE})
    # Shared files (needed by both test and benchmark)
    elseif(FILENAME MATCHES "^(json_data_generator|json_benchmark_suite|json_test_config)\\.cpp$")
        list(APPEND BENCHMARK_SOURCES ${SOURCE_FILE})
    # Exclude everything else for now - focus on benchmark runner
    endif()
endforeach()

# Debug output
message(STATUS "Discovered test sources: ${TEST_SOURCES}")
message(STATUS "Discovered benchmark sources: ${BENCHMARK_SOURCES}")

# Create test executable with discovered test files (only if we have sources)
if(TEST_SOURCES)
    add_executable(treon_tests ${TEST_SOURCES})
endif()

# Create standalone benchmark runner
add_executable(json_benchmark_runner ${BENCHMARK_SOURCES})

# Link with Qt6 Test and our libraries (only if target exists)
if(TEST_SOURCES)
    target_link_libraries(treon_tests
        PRIVATE
            Qt6::Test
            Qt6::Core
            Qt6::Widgets
            Qt6::Quick
            Qt6::QuickDialogs2
            treon_app_lib
    )
endif()

# Link benchmark runner
target_link_libraries(json_benchmark_runner
    PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
        treon_app_lib
)

# Include directories (only if target exists)
if(TEST_SOURCES)
    target_include_directories(treon_tests PRIVATE 
        ${CMAKE_SOURCE_DIR}/include
        ${CMAKE_SOURCE_DIR}/src
    )
endif()

target_include_directories(json_benchmark_runner PRIVATE 
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
)

# Enable Qt's meta-object compiler for tests (only if target exists)
if(TEST_SOURCES)
    set_target_properties(treon_tests PROPERTIES
        AUTOMOC ON
        AUTORCC ON
        AUTOUIC ON
    )
endif()

set_target_properties(json_benchmark_runner PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    AUTOUIC ON
)

# Add test to CTest (only if target exists)
if(TEST_SOURCES)
    add_test(NAME treon_tests COMMAND treon_tests)
    
    # Set test properties
    set_tests_properties(treon_tests PROPERTIES
        TIMEOUT 300
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

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
            DEPENDS json_benchmark_runner
            COMMENT "Running tests and generating coverage report"
        )
    endif()
endif()