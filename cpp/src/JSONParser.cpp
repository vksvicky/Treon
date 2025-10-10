#include "treon/JSONParser.hpp"

#include <cctype>

using namespace treon;

namespace {
constexpr bool isSpace(char c) {
    return c == ' ' || c == '\n' || c == '\r' || c == '\t' || c == '\f' || c == '\v';
}

static inline std::string_view trim(std::string_view s) {
    size_t start = 0;
    while (start < s.size() && isSpace(s[start])) { ++start; }
    size_t end = s.size();
    while (end > start && isSpace(s[end - 1])) { --end; }
    return s.substr(start, end - start);
}
}

bool JSONParser::validate(std::string_view json) noexcept {
    const auto t = trim(json);
    if (t.empty()) return false;
    const char first = t.front();
    const char last = t.back();
    if ((first == '{' && last == '}') || (first == '[' && last == ']')) {
        // Extremely lightweight structural check for bootstrapping TDD
        return true;
    }
    return false;
}

std::shared_ptr<JSONNode> JSONParser::parse(std::string_view json) {
    // Placeholder: produce a null node for now; real parser will follow TDD
    (void)json;
    return JSONNode::makeNull();
}

