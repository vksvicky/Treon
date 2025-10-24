//
//  JSONTreeBuilder.swift
//  Treon
//
//  Created by Vivek on 2024-10-19.
//  Copyright © 2024 Treon. All rights reserved.
//

import Foundation
import OSLog

/// Handles JSON tree building with performance optimizations for large files
class OptimizedJSONTreeBuilder {
    private static let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "JSONTreeBuilder")
    
    /// Builds a JSON tree with streaming approach for large files
    static func buildStreamingTree(from data: Data) throws -> JSONNode {
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 STREAMING: Starting streaming tree build")
        
        // Parse JSON object
        let rootObj = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers])
        
        // Build only the root level initially, children will be loaded on demand
        // For very large files, be more aggressive about limiting initial children
        let maxDepth = data.count > 50 * 1024 * 1024 ? 1 : 2 // 1 level for >50MB files
        let root = try buildStreamingNode(from: rootObj, key: nil, currentPath: "$", maxDepth: maxDepth)
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("📊 STREAMING: Completed in \(String(format: "%.3f", totalTime))s")
        
        return root
    }
    
    /// Builds an ultra-conservative tree for very large files (>100MB)
    static func buildUltraConservativeTree(from data: Data) throws -> JSONNode {
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 ULTRA-CONSERVATIVE: Starting ultra-conservative tree build")
        
        // Parse JSON object
        let rootObj = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers])
        
        // Build only the root level with minimal children
        let root = try buildUltraConservativeNode(from: rootObj, key: nil, currentPath: "$", maxDepth: 1)
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("📊 ULTRA-CONSERVATIVE: Completed in \(String(format: "%.3f", totalTime))s")
        
        return root
    }
    
    /// Builds a streaming node with depth limiting
    private static func buildStreamingNode(from any: Any, key: String?, currentPath: String, maxDepth: Int) throws -> JSONNode {
        if maxDepth <= 0 {
            // Return a placeholder node for deep levels
            return JSONNode(key: key, value: .string("..."), children: [], path: currentPath)
        }
        
        if let dict = any as? [String: Any] {
            var children: [JSONNode] = []
            
            // More aggressive limiting for very large files
            let maxChildren = maxDepth <= 1 ? 20 : 100 // Only 20 children for top level of large files
            children.reserveCapacity(min(dict.count, maxChildren))
            
            let childCount = min(dict.count, maxChildren)
            let sortedKeys = Array(dict.keys).sorted()
            
            for i in 0..<childCount {
                let k = sortedKeys[i]
                let v = dict[k]!
                let child = try buildStreamingNode(from: v, key: k, currentPath: currentPath + "." + k, maxDepth: maxDepth - 1)
                children.append(child)
            }
            
            // Add a placeholder for remaining children if any
            if dict.count > maxChildren {
                let placeholder = JSONNode(key: "...", value: .string("+\(dict.count - maxChildren) more items"), children: [], path: currentPath + "._more")
                children.append(placeholder)
            }
            
            return JSONNode(key: key, value: .object, children: children, path: currentPath)
        } else if let arr = any as? [Any] {
            var children: [JSONNode] = []
            
            // More aggressive limiting for very large arrays
            let maxItems = maxDepth <= 1 ? 10 : 50 // Only 10 items for top level of large files
            children.reserveCapacity(min(arr.count, maxItems))
            
            let itemCount = min(arr.count, maxItems)
            for i in 0..<itemCount {
                let v = arr[i]
                let child = try buildStreamingNode(from: v, key: String(i), currentPath: currentPath + "[\(i)]", maxDepth: maxDepth - 1)
                children.append(child)
            }
            
            // Add a placeholder for remaining items if any
            if arr.count > maxItems {
                let placeholder = JSONNode(key: "...", value: .string("+\(arr.count - maxItems) more items"), children: [], path: currentPath + "[_more]")
                children.append(placeholder)
            }
            
            return JSONNode(key: key, value: .array, children: children, path: currentPath)
        } else if let s = any as? String {
            return JSONNode(key: key, value: .string(s), children: [], path: currentPath)
        } else if let n = any as? NSNumber {
            return JSONNode(key: key, value: .number(n.doubleValue), children: [], path: currentPath)
        } else if let b = any as? Bool {
            return JSONNode(key: key, value: .bool(b), children: [], path: currentPath)
        } else if any is NSNull {
            return JSONNode(key: key, value: .null, children: [], path: currentPath)
        } else {
            throw NSError(domain: "club.cycleruncode.treon", code: 10, userInfo: [NSLocalizedDescriptionKey: "Unsupported JSON type"])
        }
    }
    
    /// Builds an ultra-conservative node with minimal children
    private static func buildUltraConservativeNode(from any: Any, key: String?, currentPath: String, maxDepth: Int) throws -> JSONNode {
        if maxDepth <= 0 {
            // Return a placeholder node for deep levels
            return JSONNode(key: key, value: .string("..."), children: [], path: currentPath)
        }
        
        if let dict = any as? [String: Any] {
            var children: [JSONNode] = []
            
            // Ultra-conservative: only 5 children for very large files
            let maxChildren = 5
            children.reserveCapacity(min(dict.count, maxChildren))
            
            let childCount = min(dict.count, maxChildren)
            let sortedKeys = Array(dict.keys).sorted()
            
            for i in 0..<childCount {
                let k = sortedKeys[i]
                let _ = dict[k]! // Don't build children for ultra-conservative mode
                let child = JSONNode(key: k, value: .string("..."), children: [], path: currentPath + "." + k)
                children.append(child)
            }
            
            // Add a placeholder for remaining children if any
            if dict.count > maxChildren {
                let placeholder = JSONNode(key: "...", value: .string("+\(dict.count - maxChildren) more items"), children: [], path: currentPath + "._more")
                children.append(placeholder)
            }
            
            return JSONNode(key: key, value: .object, children: children, path: currentPath)
        } else if let arr = any as? [Any] {
            var children: [JSONNode] = []
            
            // Ultra-conservative: only 3 array items for very large files
            let maxItems = 3
            children.reserveCapacity(min(arr.count, maxItems))
            
            let itemCount = min(arr.count, maxItems)
            for i in 0..<itemCount {
                // Don't build children for ultra-conservative mode
                let child = JSONNode(key: String(i), value: .string("..."), children: [], path: currentPath + "[\(i)]")
                children.append(child)
            }
            
            // Add a placeholder for remaining items if any
            if arr.count > maxItems {
                let placeholder = JSONNode(key: "...", value: .string("+\(arr.count - maxItems) more items"), children: [], path: currentPath + "[_more]")
                children.append(placeholder)
            }
            
            return JSONNode(key: key, value: .array, children: children, path: currentPath)
        } else if let s = any as? String {
            return JSONNode(key: key, value: .string(s), children: [], path: currentPath)
        } else if let n = any as? NSNumber {
            return JSONNode(key: key, value: .number(n.doubleValue), children: [], path: currentPath)
        } else if let b = any as? Bool {
            return JSONNode(key: key, value: .bool(b), children: [], path: currentPath)
        } else if any is NSNull {
            return JSONNode(key: key, value: .null, children: [], path: currentPath)
        } else {
            throw NSError(domain: "club.cycleruncode.treon", code: 10, userInfo: [NSLocalizedDescriptionKey: "Unsupported JSON type"])
        }
    }
}
