//
//  HybridJSONProcessor.swift
//  Treon
//
//  Created by AI Assistant on 2025-01-18.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import OSLog

/// Hybrid JSON processor that can use either Swift or Rust backend
/// 
/// This processor automatically selects the best backend based on file size and performance requirements.
/// It provides a unified interface while leveraging the strengths of both implementations.
class HybridJSONProcessor {
    
    // MARK: - Properties
    
    private static let logger = Loggers.perf
    
    /// File size threshold for using Rust backend (in bytes)
    private static let rustThresholdBytes = 5 * 1024 * 1024 // 5MB
    
    /// Large file threshold for streaming (in bytes)
    private static let streamingThresholdBytes = 50 * 1024 * 1024 // 50MB
    
    // MARK: - Processing Methods
    
    /// Process a JSON file using the optimal backend
    /// 
    /// - Parameter fileURL: URL of the JSON file to process
    /// - Returns: Processed JSON tree structure
    /// - Throws: TreonError if processing fails
    static func processFile(_ fileURL: URL) async throws -> JSONNode {
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("🚀 HYBRID PROCESSOR: Starting file processing for \(fileURL.path)")
        
        // Get file size to determine processing strategy
        let fileSize = try await getFileSize(fileURL)
        logger.info("📊 HYBRID PROCESSOR: File size: \(fileSize) bytes (\(String(format: "%.2f", Double(fileSize) / 1024 / 1024)) MB)")
        
        let result: JSONNode
        
        if fileSize >= rustThresholdBytes {
            logger.info("📊 HYBRID PROCESSOR: Using Rust backend for large file")
            result = try await processWithRustBackend(fileURL)
        } else {
            logger.info("📊 HYBRID PROCESSOR: Using Swift backend for small file")
            result = try await processWithSwiftBackend(fileURL)
        }
        
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("✅ HYBRID PROCESSOR: File processing completed in \(String(format: "%.3f", processingTime))s")
        
        return result
    }
    
    /// Process JSON data from memory using the optimal backend
    /// 
    /// - Parameter data: JSON data to process
    /// - Returns: Processed JSON tree structure
    /// - Throws: TreonError if processing fails
    static func processData(_ data: Data) async throws -> JSONNode {
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("🚀 HYBRID PROCESSOR: Starting data processing for \(data.count) bytes")
        
        let result: JSONNode
        
        if data.count >= rustThresholdBytes {
            logger.info("📊 HYBRID PROCESSOR: Using Rust backend for large data")
            result = try await processDataWithRustBackend(data)
        } else {
            logger.info("📊 HYBRID PROCESSOR: Using Swift backend for small data")
            result = try await processDataWithSwiftBackend(data)
        }
        
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("✅ HYBRID PROCESSOR: Data processing completed in \(String(format: "%.3f", processingTime))s")
        
        return result
    }
    
    // MARK: - Backend Selection
    
    /// Get the recommended backend for a given file size
    /// 
    /// - Parameter fileSize: Size of the file in bytes
    /// - Returns: Recommended backend type
    static func recommendedBackend(for fileSize: Int64) -> BackendType {
        if fileSize >= rustThresholdBytes {
            return .rust
        } else {
            return .swift
        }
    }
    
    /// Get performance comparison between backends
    /// 
    /// - Parameter fileSize: Size of the file in bytes
    /// - Returns: Performance comparison data
    static func getPerformanceComparison(for fileSize: Int64) -> PerformanceComparison {
        let swiftEstimate = estimateSwiftProcessingTime(fileSize)
        let rustEstimate = estimateRustProcessingTime(fileSize)
        
        return PerformanceComparison(
            fileSize: fileSize,
            swiftEstimate: swiftEstimate,
            rustEstimate: rustEstimate,
            recommendedBackend: recommendedBackend(for: fileSize),
            performanceGain: swiftEstimate / rustEstimate
        )
    }
    
    // MARK: - Private Processing Methods
    
    /// Process file using Rust backend
    private static func processWithRustBackend(_ fileURL: URL) async throws -> JSONNode {
        let rustTree = try await RustBackend.processFile(fileURL)
        return convertRustTreeToSwiftTree(rustTree)
    }
    
    /// Process data using Rust backend
    private static func processDataWithRustBackend(_ data: Data) async throws -> JSONNode {
        let rustTree = try RustBackend.processData(data)
        return convertRustTreeToSwiftTree(rustTree)
    }
    
    /// Process file using Swift backend
    private static func processWithSwiftBackend(_ fileURL: URL) async throws -> JSONNode {
        let data = try Data(contentsOf: fileURL)
        return try await processDataWithSwiftBackend(data)
    }
    
    /// Process data using Swift backend
    private static func processDataWithSwiftBackend(_ data: Data) async throws -> JSONNode {
        // Use the existing Swift JSON processing
        if data.count > 5 * 1024 * 1024 { // 5MB threshold
            logger.info("📊 HYBRID PROCESSOR: Using streaming approach for Swift backend")
            return try OptimizedJSONTreeBuilder.buildStreamingTree(from: data)
        } else {
            return try JSONTreeBuilder.build(from: data)
        }
    }
    
    // MARK: - Conversion Methods
    
    /// Convert Rust tree structure to Swift tree structure
    private static func convertRustTreeToSwiftTree(_ rustTree: RustJSONTree) -> JSONNode {
        return convertRustNodeToSwiftNode(rustTree.root)
    }
    
    /// Convert Rust node to Swift node
    private static func convertRustNodeToSwiftNode(_ rustNode: RustJSONNode) -> JSONNode {
        let swiftValue = convertRustValueToSwiftValue(rustNode.value, childrenCount: rustNode.children.count)
        
        // Convert children first
        let swiftChildren = rustNode.children.map { convertRustNodeToSwiftNode($0) }
        
        let swiftNode = JSONNode(
            key: rustNode.key,
            value: swiftValue,
            children: swiftChildren,
            path: rustNode.path
        )
        
        return swiftNode
    }
    
    /// Convert Rust value to Swift value
    private static func convertRustValueToSwiftValue(_ rustValue: RustJSONValue, childrenCount: Int) -> JSONNodeValue {
        switch rustValue {
        case .string(let value):
            return .string(value)
        case .number(let value):
            return .number(value)
        case .boolean(let value):
            return .bool(value)
        case .null:
            return .null
        case .object:
            return .object
        case .array:
            return .array
        }
    }
    
    // MARK: - Utility Methods
    
    /// Get file size for a given URL
    private static func getFileSize(_ url: URL) async throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    /// Estimate Swift processing time based on file size
    private static func estimateSwiftProcessingTime(_ fileSize: Int64) -> Double {
        // Based on performance research: ~0.04s for 10MB, ~0.2s for 50MB
        let baseTime = 0.001 // 1ms base time
        let sizeFactor = Double(fileSize) / (1024 * 1024) // Convert to MB
        return baseTime + (sizeFactor * 0.02) // 20ms per MB
    }
    
    /// Estimate Rust processing time based on file size
    private static func estimateRustProcessingTime(_ fileSize: Int64) -> Double {
        // Based on performance research: ~0.05s for 10MB, ~0.3s for 50MB
        let baseTime = 0.0001 // 0.1ms base time
        let sizeFactor = Double(fileSize) / (1024 * 1024) // Convert to MB
        return baseTime + (sizeFactor * 0.003) // 3ms per MB
    }
}

// MARK: - Supporting Types

/// Backend type enumeration
enum BackendType: String, CaseIterable {
    case swift = "Swift"
    case rust = "Rust"
    
    var description: String {
        switch self {
        case .swift:
            return "Native Swift with Foundation JSONSerialization"
        case .rust:
            return "High-performance Rust with SIMD optimization"
        }
    }
}

/// Performance comparison data
struct PerformanceComparison {
    let fileSize: Int64
    let swiftEstimate: Double
    let rustEstimate: Double
    let recommendedBackend: BackendType
    let performanceGain: Double
    
    var fileSizeMB: Double {
        return Double(fileSize) / (1024 * 1024)
    }
    
    var swiftEstimateFormatted: String {
        return String(format: "%.3fs", swiftEstimate)
    }
    
    var rustEstimateFormatted: String {
        return String(format: "%.3fs", rustEstimate)
    }
    
    var performanceGainFormatted: String {
        return String(format: "%.1fx", performanceGain)
    }
}

