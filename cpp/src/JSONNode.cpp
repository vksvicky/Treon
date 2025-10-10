#include "treon/JSONNode.hpp"

using namespace treon;

std::shared_ptr<JSONNode> JSONNode::makeNull() {
    auto node = std::make_shared<JSONNode>();
    node->type = JSONType::Null;
    node->value = std::monostate{};
    return node;
}

std::shared_ptr<JSONNode> JSONNode::makeBoolean(bool v) {
    auto node = std::make_shared<JSONNode>();
    node->type = JSONType::Boolean;
    node->value = v;
    return node;
}

std::shared_ptr<JSONNode> JSONNode::makeNumber(double v) {
    auto node = std::make_shared<JSONNode>();
    node->type = JSONType::Number;
    node->value = v;
    return node;
}

std::shared_ptr<JSONNode> JSONNode::makeString(std::string v) {
    auto node = std::make_shared<JSONNode>();
    node->type = JSONType::String;
    node->value = std::move(v);
    return node;
}

std::shared_ptr<JSONNode> JSONNode::makeArray() {
    auto node = std::make_shared<JSONNode>();
    node->type = JSONType::Array;
    node->value = Array{};
    return node;
}

std::shared_ptr<JSONNode> JSONNode::makeObject() {
    auto node = std::make_shared<JSONNode>();
    node->type = JSONType::Object;
    node->value = Object{};
    return node;
}

