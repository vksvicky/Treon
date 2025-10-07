import Foundation
import Combine

public enum JSONNodeValue: Equatable {
    case object
    case array
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
}

@MainActor
public final class TreeExpansionState: ObservableObject {
    @Published public private(set) var expandedIds: Set<String> = []

    public init() {}

    // Avoid actor-teardown interaction during XCTest memory checking
    nonisolated(unsafe) deinit {}

    @inlinable public func isExpanded(_ node: JSONNode) -> Bool { expandedIds.contains(node.id) }

    public func expandAll(root: JSONNode) {
        var ids: Set<String> = []
        collectIds(node: root, into: &ids)
        expandedIds = ids
    }

    public func resetAll() { expandedIds.removeAll() }

    public func expand(node: JSONNode, includeDescendants: Bool) {
        expandedIds.insert(node.id)
        if includeDescendants { addDescendantIds(of: node) }
    }

    public func collapse(node: JSONNode, includeDescendants: Bool) {
        expandedIds.remove(node.id)
        if includeDescendants { removeDescendantIds(of: node) }
    }

    public func setExpanded(_ expanded: Bool, for node: JSONNode) {
        if expanded { expandedIds.insert(node.id) } else { expandedIds.remove(node.id) }
    }

    private func collectIds(node: JSONNode, into set: inout Set<String>) {
        set.insert(node.id)
        for child in node.children { collectIds(node: child, into: &set) }
    }

    private func addDescendantIds(of node: JSONNode) {
        var stack: [JSONNode] = node.children
        while let n = stack.popLast() {
            expandedIds.insert(n.id)
            stack.append(contentsOf: n.children)
        }
    }

    private func removeDescendantIds(of node: JSONNode) {
        var stack: [JSONNode] = node.children
        while let n = stack.popLast() {
            expandedIds.remove(n.id)
            stack.append(contentsOf: n.children)
        }
    }
}

public struct JSONNode: Identifiable {
    public let id: String
    public let key: String?
    public let value: JSONNodeValue
    public let children: [JSONNode]
    public let path: String
    
    public init(key: String?, value: JSONNodeValue, children: [JSONNode] = [], path: String) {
        self.id = path
        self.key = key
        self.value = value
        self.children = children
        self.path = path
    }
}

public extension JSONNode {
    var displayTitle: String {
        // Root node (no key)
        guard let key = key else {
            switch value {
            case .object: return "Root Object"
            case .array: return "Root Array"
            default: return "Root"
            }
        }
        // Array indices use bracketed form
        let isNumericKey = !key.isEmpty && key.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
        if isNumericKey { return "[\(key)]" }
        // Object key as-is
        return key
    }
}

public enum JSONTreeBuilder {
    public static func build(from data: Data) throws -> JSONNode {
        let rootObj = try JSONSerialization.jsonObject(with: data, options: [])
        let root = try node(from: rootObj, key: nil, currentPath: "$")
        return root
    }

    private static func node(from any: Any, key: String?, currentPath: String) throws -> JSONNode {
        if let dict = any as? [String: Any] {
            var children: [JSONNode] = []
            for (k, v) in dict {
                let childPath = currentPath + "." + escapeKey(k)
                let child = try node(from: v, key: k, currentPath: childPath)
                children.append(child)
            }
            return JSONNode(key: key, value: .object, children: children.sorted { ($0.key ?? "") < ($1.key ?? "") }, path: currentPath)
        } else if let arr = any as? [Any] {
            var children: [JSONNode] = []
            for (i, v) in arr.enumerated() {
                let childPath = currentPath + "[" + String(i) + "]"
                let child = try node(from: v, key: String(i), currentPath: childPath)
                children.append(child)
            }
            return JSONNode(key: key, value: .array, children: children, path: currentPath)
        } else if let s = any as? String {
            return JSONNode(key: key, value: .string(s), path: currentPath)
        } else if let n = any as? NSNumber {
            if CFGetTypeID(n) == CFBooleanGetTypeID() {
                return JSONNode(key: key, value: .bool(n.boolValue), path: currentPath)
            } else {
                return JSONNode(key: key, value: .number(n.doubleValue), path: currentPath)
            }
        } else if any is NSNull {
            return JSONNode(key: key, value: .null, path: currentPath)
        } else {
            throw NSError(domain: "club.cycleruncode.treon", code: 10, userInfo: [NSLocalizedDescriptionKey: "Unsupported JSON type"])
        }
    }

    private static func escapeKey(_ key: String) -> String {
        // Simple escape for dots in keys
        return key.replacingOccurrences(of: ".", with: "\\.")
    }
}


