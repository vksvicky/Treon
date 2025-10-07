import Foundation

public enum JSONNodeValue: Equatable {
    case object
    case array
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
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


