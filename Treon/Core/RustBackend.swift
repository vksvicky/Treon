//
//  RustBackend.swift
//  Treon
//
//  Created by AI Assistant on 2025-01-18.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import OSLog

/// Swift-Rust FFI bridge for high-performance JSON processing
/// 
/// This class provides a clean Swift interface to the Rust backend,
/// handling the complexity of C FFI while maintaining Swift's safety and ergonomics.
class RustBackend {
    
    // MARK: - Properties
    
    private static let logger = Loggers.perf
    private static var isInitialized = false
    
    // MARK: - Initialization
    
    /// Initialize the Rust backend
    /// This should be called once when the app starts
    static func initialize() {
        guard !isInitialized else { return }
        
        logger.info("🚀 Initializing Rust backend...")
        treon_rust_init()
        isInitialized = true
        logger.info("✅ Rust backend initialized successfully")
    }
    
    // MARK: - JSON Processing
    
    /// Process a JSON file using the Rust backend
    /// 
    /// - Parameter fileURL: URL of the JSON file to process
    /// - Returns: Processed JSON tree structure
    /// - Throws: TreonError if processing fails
    static func processFile(_ fileURL: URL) async throws -> RustJSONTree {
        guard isInitialized else {
            throw TreonError.backendNotInitialized
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 RUST BACKEND: Starting file processing for \(fileURL.path)")
        
        let filePath = fileURL.path
        let cString = filePath.cString(using: .utf8)!
        
        let resultPtr = treon_rust_process_file(cString)
        defer { treon_rust_free_string(resultPtr) }
        
        guard let resultPtr = resultPtr else {
            logger.error("❌ RUST BACKEND: Failed to process file")
            throw TreonError.processingFailed("Failed to process file with Rust backend")
        }
        
        let resultString = String(cString: resultPtr)
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("📊 RUST BACKEND: File processing completed in \(String(format: "%.3f", processingTime))s")
        
        do {
            let tree = try JSONDecoder().decode(RustJSONTree.self, from: resultString.data(using: .utf8)!)
            logger.info("📊 RUST BACKEND: Successfully parsed tree with \(tree.totalNodes) nodes")
            return tree
        } catch {
            logger.error("❌ RUST BACKEND: Failed to decode result: \(error)")
            throw TreonError.processingFailed("Failed to decode Rust backend result: \(error.localizedDescription)")
        }
    }
    
    /// Process JSON data from memory using the Rust backend
    /// 
    /// - Parameter data: JSON data to process
    /// - Returns: Processed JSON tree structure
    /// - Throws: TreonError if processing fails
    static func processData(_ data: Data) async throws -> RustJSONTree {
        guard isInitialized else {
            throw TreonError.backendNotInitialized
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 RUST BACKEND: Starting data processing for \(data.count) bytes")
        
        let resultPtr = data.withUnsafeBytes { bytes in
            treon_rust_process_data(bytes.bindMemory(to: UInt8.self).baseAddress!, data.count)
        }
        defer { treon_rust_free_string(resultPtr) }
        
        guard let resultPtr = resultPtr else {
            logger.error("❌ RUST BACKEND: Failed to process data")
            throw TreonError.processingFailed("Failed to process data with Rust backend")
        }
        
        let resultString = String(cString: resultPtr)
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("📊 RUST BACKEND: Data processing completed in \(String(format: "%.3f", processingTime))s")
        
        do {
            let tree = try JSONDecoder().decode(RustJSONTree.self, from: resultString.data(using: .utf8)!)
            logger.info("📊 RUST BACKEND: Successfully parsed tree with \(tree.totalNodes) nodes")
            return tree
        } catch {
            logger.error("❌ RUST BACKEND: Failed to decode result: \(error)")
            throw TreonError.processingFailed("Failed to decode Rust backend result: \(error.localizedDescription)")
        }
    }
    
    /// Get performance statistics from the Rust backend
    /// 
    /// - Returns: Performance statistics
    static func getStats() -> RustBackendStats? {
        guard isInitialized else { return nil }
        
        let statsPtr = treon_rust_get_stats()
        defer { treon_rust_free_string(statsPtr) }
        
        guard let statsPtr = statsPtr else { return nil }
        
        let statsString = String(cString: statsPtr)
        
        do {
            let stats = try JSONDecoder().decode(RustBackendStats.self, from: statsString.data(using: .utf8)!)
            return stats
        } catch {
            logger.error("❌ RUST BACKEND: Failed to decode stats: \(error)")
            return nil
        }
    }
}

// MARK: - Rust Backend Data Structures

/// JSON tree structure returned by the Rust backend
struct RustJSONTree: Codable {
    let root: RustJSONNode
    let totalNodes: Int
    let totalSizeBytes: Int
    let stats: RustProcessingStats
    
    enum CodingKeys: String, CodingKey {
        case root
        case totalNodes = "total_nodes"
        case totalSizeBytes = "total_size_bytes"
        case stats
    }
}

/// JSON node structure from the Rust backend
struct RustJSONNode: Codable {
    let key: String
    let path: String
    let value: RustJSONValue
    let children: [RustJSONNode]
    let expanded: Bool
    let fullyLoaded: Bool
    let metadata: RustNodeMetadata
    
    enum CodingKeys: String, CodingKey {
        case key, path, value, children, expanded
        case fullyLoaded = "fully_loaded"
        case metadata
    }
}

/// JSON value type from the Rust backend
enum RustJSONValue: Codable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null
    case object
    case array
    
    enum CodingKeys: String, CodingKey {
        case string = "String"
        case number = "Number"
        case boolean = "Boolean"
        case null = "Null"
        case object = "Object"
        case array = "Array"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.typeMismatch(RustJSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .object, .array:
            // These are handled by the tree structure
            break
        }
    }
    
    var displayName: String {
        switch self {
        case .string: return "String"
        case .number: return "Number"
        case .boolean: return "Boolean"
        case .null: return "null"
        case .object: return "Object"
        case .array: return "Array"
        }
    }
    
    func displayNameWithCount(_ count: Int) -> String {
        switch self {
        case .object: return "Object{\(count)}"
        case .array: return "Array[\(count)]"
        default: return displayName
        }
    }
}

/// Node metadata from the Rust backend
struct RustNodeMetadata: Codable {
    let sizeBytes: Int
    let depth: Int
    let descendantCount: Int
    let streamed: Bool
    let processingTimeMs: UInt64
    
    enum CodingKeys: String, CodingKey {
        case sizeBytes = "size_bytes"
        case depth
        case descendantCount = "descendant_count"
        case streamed
        case processingTimeMs = "processing_time_ms"
    }
}

/// Processing statistics from the Rust backend
struct RustProcessingStats: Codable {
    let processingTimeMs: UInt64
    let parsingTimeMs: UInt64
    let treeBuildingTimeMs: UInt64
    let peakMemoryBytes: Int
    let usedStreaming: Bool
    let streamingChunks: Int
    
    enum CodingKeys: String, CodingKey {
        case processingTimeMs = "processing_time_ms"
        case parsingTimeMs = "parsing_time_ms"
        case treeBuildingTimeMs = "tree_building_time_ms"
        case peakMemoryBytes = "peak_memory_bytes"
        case usedStreaming = "used_streaming"
        case streamingChunks = "streaming_chunks"
    }
}

/// Backend statistics
struct RustBackendStats: Codable {
    let backend: String
    let version: String
    let features: [String]
    let performance: [String: String]
}

// MARK: - C FFI Declarations

/// Initialize the Rust backend
@_cdecl("treon_rust_init")
func treon_rust_init()

/// Process a JSON file
@_cdecl("treon_rust_process_file")
func treon_rust_process_file(_ filePath: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

/// Process JSON data from memory
@_cdecl("treon_rust_process_data")
func treon_rust_process_data(_ data: UnsafePointer<UInt8>, _ length: Int) -> UnsafeMutablePointer<CChar>?

/// Free a string returned by the Rust backend
@_cdecl("treon_rust_free_string")
func treon_rust_free_string(_ ptr: UnsafeMutablePointer<CChar>)

/// Get performance statistics
@_cdecl("treon_rust_get_stats")
func treon_rust_get_stats() -> UnsafeMutablePointer<CChar>?

// MARK: - Error Extensions

extension TreonError {
    static let backendNotInitialized = TreonError.generic("Rust backend not initialized")
    static func processingFailed(_ reason: String) -> TreonError {
        return .generic("Processing failed: \(reason)")
    }
}
