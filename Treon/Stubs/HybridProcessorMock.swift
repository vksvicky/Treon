//
//  HybridProcessorMock.swift
//  Treon
//
//  Created by AI Assistant on 2025-01-18.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation

/// Mock implementation of HybridJSONProcessor for testing
/// 
/// This mock allows us to test the UI and other components without depending on the actual
/// Rust backend or complex JSON processing logic.
class HybridProcessorMock {
    
    // MARK: - Mock Configuration
    
    /// Whether the mock should simulate success or failure
    var shouldSucceed = true
    
    /// Delay to simulate processing time
    var processingDelay: TimeInterval = 0.1
    
    /// Mock performance comparison data
    var mockPerformanceComparison: PerformanceComparison?
    
    /// Mock JSON tree to return
    var mockJSONTree: JSONNode?
    
    // MARK: - Mock Implementation
    
    /// Mock process data method
    func processData(_ data: Data) async throws -> JSONNode {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: UInt64(processingDelay * 1_000_000_000))
        
        if !shouldSucceed {
            throw TreonError.generic("Mock processing failed")
        }
        
        // Return mock tree or create a simple one
        if let mockTree = mockJSONTree {
            return mockTree
        } else {
            return createMockJSONTree(from: data)
        }
    }
    
    /// Mock process file method
    func processFile(_ url: URL) async throws -> JSONNode {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: UInt64(processingDelay * 1_000_000_000))
        
        if !shouldSucceed {
            throw TreonError.generic("Mock file processing failed")
        }
        
        // Return mock tree or create a simple one
        if let mockTree = mockJSONTree {
            return mockTree
        } else {
            return createMockJSONTreeFromFile(url)
        }
    }
    
    /// Mock performance comparison
    func getPerformanceComparison(for fileSize: Int64) -> PerformanceComparison {
        if let mockComparison = mockPerformanceComparison {
            return mockComparison
        }
        
        // Create realistic mock comparison
        let swiftEstimate = Double(fileSize) / (1024 * 1024) * 0.02 // 20ms per MB
        let rustEstimate = Double(fileSize) / (1024 * 1024) * 0.003 // 3ms per MB
        let recommendedBackend: BackendType = fileSize > 5 * 1024 * 1024 ? .rust : .swift
        let performanceGain = swiftEstimate / rustEstimate
        
        return PerformanceComparison(
            fileSize: fileSize,
            swiftEstimate: swiftEstimate,
            rustEstimate: rustEstimate,
            recommendedBackend: recommendedBackend,
            performanceGain: performanceGain
        )
    }
    
    /// Mock recommended backend
    func recommendedBackend(for fileSize: Int64) -> BackendType {
        return fileSize > 5 * 1024 * 1024 ? .rust : .swift
    }
    
    // MARK: - Mock Data Creation
    
    /// Create a mock JSON tree from data
    private func createMockJSONTree(from data: Data) -> JSONNode {
        let root = JSONNode(key: "", path: "$", value: .object)
        
        // Add some mock children based on data size
        let dataSize = data.count
        let childCount = min(dataSize / 1000, 10) // Up to 10 children
        
        for i in 0..<childCount {
            let child = JSONNode(
                key: "mock_key_\(i)",
                path: "$.mock_key_\(i)",
                value: i % 2 == 0 ? .string("mock_value_\(i)") : .number(Double(i))
            )
            root.addChild(child)
        }
        
        return root
    }
    
    /// Create a mock JSON tree from file URL
    private func createMockJSONTreeFromFile(_ url: URL) -> JSONNode {
        let root = JSONNode(key: "", path: "$", value: .object)
        
        // Add mock children based on filename
        let filename = url.lastPathComponent
        let child = JSONNode(
            key: "filename",
            path: "$.filename",
            value: .string(filename)
        )
        root.addChild(child)
        
        let sizeChild = JSONNode(
            key: "size",
            path: "$.size",
            value: .number(1024.0)
        )
        root.addChild(sizeChild)
        
        return root
    }
}

// MARK: - Mock Extensions

extension HybridProcessorMock {
    
    /// Configure mock to return a specific JSON tree
    func configureMockTree(_ tree: JSONNode) {
        mockJSONTree = tree
    }
    
    /// Configure mock to return a specific performance comparison
    func configureMockPerformanceComparison(_ comparison: PerformanceComparison) {
        mockPerformanceComparison = comparison
    }
    
    /// Configure mock to simulate failure
    func configureToFail() {
        shouldSucceed = false
    }
    
    /// Configure mock to simulate success
    func configureToSucceed() {
        shouldSucceed = true
    }
    
    /// Configure mock processing delay
    func configureProcessingDelay(_ delay: TimeInterval) {
        processingDelay = delay
    }
}

// MARK: - Test Helpers

extension HybridProcessorMock {
    
    /// Create a mock JSON tree for testing
    static func createTestJSONTree() -> JSONNode {
        let root = JSONNode(key: "", path: "$", value: .object)
        
        // Add test children
        let nameChild = JSONNode(key: "name", path: "$.name", value: .string("Test"))
        root.addChild(nameChild)
        
        let valueChild = JSONNode(key: "value", path: "$.value", value: .number(42.0))
        root.addChild(valueChild)
        
        let activeChild = JSONNode(key: "active", path: "$.active", value: .bool(true))
        root.addChild(activeChild)
        
        // Add nested object
        let nestedChild = JSONNode(key: "nested", path: "$.nested", value: .object)
        let nestedValue = JSONNode(key: "data", path: "$.nested.data", value: .string("nested_value"))
        nestedChild.addChild(nestedValue)
        root.addChild(nestedChild)
        
        // Add array
        let arrayChild = JSONNode(key: "items", path: "$.items", value: .array)
        for i in 0..<3 {
            let item = JSONNode(key: "\(i)", path: "$.items[\(i)]", value: .number(Double(i + 1)))
            arrayChild.addChild(item)
        }
        root.addChild(arrayChild)
        
        return root
    }
    
    /// Create a mock performance comparison for testing
    static func createTestPerformanceComparison() -> PerformanceComparison {
        return PerformanceComparison(
            fileSize: 5 * 1024 * 1024, // 5MB
            swiftEstimate: 0.1, // 100ms
            rustEstimate: 0.015, // 15ms
            recommendedBackend: .rust,
            performanceGain: 6.67
        )
    }
}
