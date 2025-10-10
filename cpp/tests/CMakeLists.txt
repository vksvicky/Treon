# Automatically discover test files
file(GLOB_RECURSE TEST_SOURCES "*.cpp")

add_executable(tests
    ${TEST_SOURCES}
)

target_link_libraries(tests PRIVATE treon_core Qt6::Core Qt6::Test)

target_compile_definitions(tests PRIVATE QT_TESTCASE_BUILDDIR="${CMAKE_CURRENT_BINARY_DIR}")

add_test(NAME treon_tests COMMAND tests)

