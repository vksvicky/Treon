add_executable(tests
    test_json_validate.cpp
)

target_link_libraries(tests PRIVATE treon_core)

add_test(NAME treon_tests COMMAND tests)

