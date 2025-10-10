# Create separate test executables for each test file
file(GLOB_RECURSE TEST_SOURCES "test_*.cpp")

foreach(TEST_SOURCE ${TEST_SOURCES})
    get_filename_component(TEST_NAME ${TEST_SOURCE} NAME_WE)
    
    add_executable(${TEST_NAME}
        ${TEST_SOURCE}
    )
    
    target_link_libraries(${TEST_NAME} PRIVATE treon_core Qt6::Core Qt6::Test)
    target_compile_definitions(${TEST_NAME} PRIVATE QT_TESTCASE_BUILDDIR="${CMAKE_CURRENT_BINARY_DIR}")
    
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
endforeach()

