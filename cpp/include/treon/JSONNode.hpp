#pragma once

#include <string>
#include <string_view>
#include <variant>
#include <vector>
#include <memory>

namespace treon {

enum class JSONType {
    Object,
    Array,
    String,
    Number,
    Boolean,
    Null
};

struct JSONNode final {
    using ObjectMember = std::pair<std::string, std::shared_ptr<JSONNode>>;
    using Object = std::vector<ObjectMember>;
    using Array = std::vector<std::shared_ptr<JSONNode>>;

    JSONType type;
    std::variant<std::monostate, Object, Array, std::string, double, bool> value;

    static std::shared_ptr<JSONNode> makeNull();
    static std::shared_ptr<JSONNode> makeBoolean(bool v);
    static std::shared_ptr<JSONNode> makeNumber(double v);
    static std::shared_ptr<JSONNode> makeString(std::string v);
    static std::shared_ptr<JSONNode> makeArray();
    static std::shared_ptr<JSONNode> makeObject();
};

} // namespace treon

