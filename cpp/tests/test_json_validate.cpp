#include <cassert>
#include <iostream>

#include "treon/JSONParser.hpp"

using treon::JSONParser;

static void test_valid_object() {
    const char* json = "{\"a\":1}";
    assert(JSONParser::validate(json) && "object should be valid by structure");
}

static void test_valid_array() {
    const char* json = "[1,2,3]";
    assert(JSONParser::validate(json) && "array should be valid by structure");
}

static void test_invalid_value() {
    const char* json = "true";
    assert(!JSONParser::validate(json) && "bare literal not accepted by structural check");
}

int main() {
    test_valid_object();
    test_valid_array();
    test_invalid_value();
    std::cout << "All tests passed\n";
    return 0;
}

