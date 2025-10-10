#include <cassert>
#include <string>

#include "treon/JSONParser.hpp"

static std::string g_json;
static bool g_valid;

// Placeholder step handlers (no cucumber runner yet)

void given_json_string(const std::string& s) {
    g_json = s;
}

void when_validate() {
    g_valid = treon::JSONParser::validate(g_json);
}

void then_valid(bool expect) {
    assert((g_valid == expect) && "validation result mismatch");
}

