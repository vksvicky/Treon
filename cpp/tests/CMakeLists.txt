# Tests CMakeLists.txt

# Find Qt6 Test component
find_package(Qt6 REQUIRED COMPONENTS Test)

# Create test executable with individual test files
add_executable(treon_tests
    test_application.cpp
)

# Link with Qt6 Test and our libraries
target_link_libraries(treon_tests
    PRIVATE
        Qt6::Test
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
        Qt6::QuickDialogs2
        treon_app_lib
)

# Include directories
target_include_directories(treon_tests PRIVATE 
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
)

# Enable Qt's meta-object compiler for tests
set_target_properties(treon_tests PROPERTIES
    AUTOMOC ON
    AUTORCC ON
    AUTOUIC ON
)

# Add test to CTest
add_test(NAME treon_tests COMMAND treon_tests)

# Set test properties
set_tests_properties(treon_tests PROPERTIES
    TIMEOUT 300
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

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
            DEPENDS treon_tests
            COMMENT "Running tests and generating coverage report"
        )
    endif()
endif()