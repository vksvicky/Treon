#pragma once

#include <memory>
#include <string_view>

#include "treon/JSONNode.hpp"

namespace treon {

class JSONParser final {
public:
    // Minimal API for parity and TDD bootstrapping
    static bool validate(std::string_view json) noexcept;

    // Future: parse into node tree (streaming later)
    static std::shared_ptr<JSONNode> parse(std::string_view json);
};

} // namespace treon

