import Foundation
import Combine
import OSLog

public enum JSONNodeValue: Equatable {
    case object
    case array
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    
    nonisolated public static func == (lhs: JSONNodeValue, rhs: JSONNodeValue) -> Bool {
        switch (lhs, rhs) {
        case (.object, .object), (.array, .array), (.null, .null):
            return true
        case (.string(let l), .string(let r)):
            return l == r
        case (.number(let l), .number(let r)):
            return l == r
        case (.bool(let l), .bool(let r)):
            return l == r
        default:
            return false
        }
    }
}

@MainActor
public final class TreeExpansionState: ObservableObject {
    @Published public private(set) var expandedIds: Set<String> = []

    public init() {}

    // Avoid actor-teardown interaction during XCTest memory checking
    deinit {}

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

        var dataType: String {
            switch value {
            case .string: return "String"
            case .number: return "Number"
            case .bool: return "Boolean"
            case .object: return "Object"
            case .array: return "Array"
            case .null: return "null"
            }
        }

        var typeIcon: String {
            switch value {
            case .string: return "\"\""
            case .number: return "#"
            case .bool: return "✓"
            case .object: return "{}"
            case .array: return "[]"
            case .null: return "∅"
            }
        }

        var typeIconName: String {
            switch value {
            case .string: return "string-data-type"
            case .number: return "number-data-type"
            case .bool: return "boolean-data-type"
            case .object: return "object-data-type"
            case .array: return "array-data-type"
            case .null: return "null-data-type"
            }
        }

        var enhancedDataType: String {
            switch value {
            case .string: return "String"
            case .number: return "Number"
            case .bool: return "Boolean"
            case .object: return "Object{\(children.count)}"
            case .array: return "Array[\(children.count)]"
            case .null: return "null"
            }
        }
    }

public enum JSONTreeBuilder {
    private static let logger = Loggers.perf
    
    public static func build(from data: Data) throws -> JSONNode {
        let buildStartTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 TREE BUILDER START: Building tree from \(data.count) bytes")
        
        // Use optimized JSONSerialization with better options
        let serializationStart = CFAbsoluteTimeGetCurrent()
        let rootObj = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers])
        let serializationTime = CFAbsoluteTimeGetCurrent() - serializationStart
        logger.debug("📊 TREE BUILDER STEP 1: JSONSerialization: \(String(format: "%.3f", serializationTime))s")
        
        let nodeBuildStart = CFAbsoluteTimeGetCurrent()
        let root = try buildOptimizedNode(from: rootObj, key: nil, currentPath: "$")
        let nodeBuildTime = CFAbsoluteTimeGetCurrent() - nodeBuildStart
        logger.debug("📊 TREE BUILDER STEP 2: Node building: \(String(format: "%.3f", nodeBuildTime))s")
        
        let totalBuildTime = CFAbsoluteTimeGetCurrent() - buildStartTime
        logger.info("📊 TREE BUILDER TOTAL: \(String(format: "%.3f", totalBuildTime))s")
        
        return root
    }
    
    // Optimized node building with reduced allocations and path building
    private static func buildOptimizedNode(from any: Any, key: String?, currentPath: String) throws -> JSONNode {
        if let dict = any as? [String: Any] {
            // Pre-allocate array with known capacity
            var children: [JSONNode] = []
            children.reserveCapacity(dict.count)
            
            // Build children without sorting initially (sort only if needed)
            for (k, v) in dict {
                let child = try buildOptimizedNode(from: v, key: k, currentPath: currentPath + "." + k)
                children.append(child)
            }
            
            // Only sort if we have many children (performance optimization)
            if children.count > 10 {
                children.sort { ($0.key ?? "") < ($1.key ?? "") }
            }
            
            return JSONNode(key: key, value: .object, children: children, path: currentPath)
        } else if let arr = any as? [Any] {
            // Pre-allocate array with known capacity
            var children: [JSONNode] = []
            children.reserveCapacity(arr.count)
            
            // Build children with index-based keys
            for (i, v) in arr.enumerated() {
                let child = try buildOptimizedNode(from: v, key: String(i), currentPath: currentPath + "[\(i)]")
                children.append(child)
            }
            
            return JSONNode(key: key, value: .array, children: children, path: currentPath)
        } else if let s = any as? String {
            return JSONNode(key: key, value: .string(s), children: [], path: currentPath)
        } else if let n = any as? NSNumber {
            // Optimize number handling
            if CFNumberIsFloatType(n) {
                return JSONNode(key: key, value: .number(n.doubleValue), children: [], path: currentPath)
            } else {
                return JSONNode(key: key, value: .number(n.doubleValue), children: [], path: currentPath)
            }
        } else if let b = any as? Bool {
            return JSONNode(key: key, value: .bool(b), children: [], path: currentPath)
        } else if any is NSNull {
            return JSONNode(key: key, value: .null, children: [], path: currentPath)
        } else {
            throw NSError(domain: "club.cycleruncode.treon", code: 10, userInfo: [NSLocalizedDescriptionKey: "Unsupported JSON type"])
        }
    }


    private static func escapeKey(_ key: String) -> String {
        // Simple escape for dots in keys
        return key.replacingOccurrences(of: ".", with: "\\.")
    }
}


