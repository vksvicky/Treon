//
//  JSONViewerHelpersTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-24.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
import AppKit
@testable import Treon

@MainActor
final class JSONViewerHelpersTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
    }
    
    // MARK: - Data Conversion Tests
    
    func testConvertTextToData() async throws {
        let testText = "Hello, World!"
        let data = try await JSONViewerHelpers.convertTextToData(testText)
        
        XCTAssertEqual(data, testText.data(using: .utf8))
        XCTAssertEqual(String(data: data, encoding: .utf8), testText)
    }
    
    func testConvertTextToDataEmpty() async throws {
        let testText = ""
        let data = try await JSONViewerHelpers.convertTextToData(testText)
        
        XCTAssertEqual(data.count, 0)
        XCTAssertEqual(String(data: data, encoding: .utf8), "")
    }
    
    func testConvertTextToDataUnicode() async throws {
        let testText = "Hello 世界 🌍"
        let data = try await JSONViewerHelpers.convertTextToData(testText)
        
        XCTAssertEqual(String(data: data, encoding: .utf8), testText)
    }
    
    // MARK: - JSON Processing Tests
    
    func testProcessJSONData() async throws {
        let jsonString = """
        {
            "name": "Test",
            "value": 42,
            "active": true
        }
        """
        let data = jsonString.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "test.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.key, nil) // Root node should have nil key
        XCTAssertEqual(result.value, .object)
        XCTAssertGreaterThan(result.children.count, 0)
    }
    
    func testProcessJSONDataInvalid() async throws {
        // Use the exact same test data as the working test
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "invalid.json",
            size: Int64(invalidJSON.count),
            modifiedDate: Date(),
            isValidJSON: false,
            errorMessage: "Invalid JSON"
        )
        
        // Test RustBackend.processData directly
        do {
            _ = try RustBackend.processData(invalidJSON, maxDepth: 0)
            XCTFail("RustBackend.processData should have thrown an error for invalid JSON")
        } catch {
            // Any error is acceptable for invalid JSON
            XCTAssertNotNil(error)
        }
        
        // Test HybridJSONProcessor.processData
        do {
            _ = try await HybridJSONProcessor.processData(invalidJSON)
            XCTFail("HybridJSONProcessor.processData should have thrown an error for invalid JSON")
        } catch {
            // Any error is acceptable for invalid JSON
            XCTAssertNotNil(error)
        }
        
        // Test JSONViewerHelpers.processJSONData
        do {
            _ = try await JSONViewerHelpers.processJSONData(invalidJSON, fileInfo: fileInfo)
            XCTFail("JSONViewerHelpers.processJSONData should have thrown an error for invalid JSON")
        } catch {
            // Any error is acceptable for invalid JSON
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Node Counting Tests
    
    func testCountNodesSimple() {
        let node = JSONNode(
            key: "root",
            value: .object,
            children: [],
            path: ""
        )
        
        let count = JSONViewerHelpers.countNodes(node)
        XCTAssertEqual(count, 1)
    }
    
    func testCountNodesWithChildren() {
        let child1 = JSONNode(key: "child1", value: .string("value1"), children: [], path: "child1")
        let child2 = JSONNode(key: "child2", value: .string("value2"), children: [], path: "child2")
        let node = JSONNode(
            key: "root",
            value: .object,
            children: [child1, child2],
            path: ""
        )
        
        let count = JSONViewerHelpers.countNodes(node)
        XCTAssertEqual(count, 3) // root + 2 children
    }
    
    func testCountNodesNested() {
        let grandchild = JSONNode(key: "grandchild", value: .string("value"), children: [], path: "child.grandchild")
        let child = JSONNode(key: "child", value: .object, children: [grandchild], path: "child")
        let node = JSONNode(
            key: "root",
            value: .object,
            children: [child],
            path: ""
        )
        
        let count = JSONViewerHelpers.countNodes(node)
        XCTAssertEqual(count, 3) // root + child + grandchild
    }
    
    func testCountNodesLargeTree() {
        // Create a tree with many nodes to test the max count limit
        var children: [JSONNode] = []
        for i in 0..<1000 {
            let child = JSONNode(
                key: "child\(i)",
                value: .string("value\(i)"),
                children: [],
                path: "child\(i)"
            )
            children.append(child)
        }
        
        let node = JSONNode(
            key: "root",
            value: .object,
            children: children,
            path: ""
        )
        
        let count = JSONViewerHelpers.countNodes(node)
        // Should be limited by maxCount (1000000)
        XCTAssertLessThanOrEqual(count, 1000000)
        XCTAssertGreaterThan(count, 1000) // Should count at least the direct children
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleParsingErrorTimeout() async {
        let timeoutError = NSError(domain: "TestDomain", code: 408, userInfo: [NSLocalizedDescriptionKey: "Request timeout"])
        var errorMessage: String?
        let expansion = TreeExpansionState()
        
        await JSONViewerHelpers.handleParsingError(
            timeoutError,
            showError: { message in
                errorMessage = message
            },
            expansion: expansion
        )
        
        XCTAssertNotNil(errorMessage)
        XCTAssertTrue(errorMessage!.contains("File too large"))
        XCTAssertTrue(errorMessage!.contains("Tree view will show limited content"))
    }
    
    func testHandleParsingErrorGeneric() async {
        let genericError = NSError(domain: "TestDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Generic error"])
        var errorMessage: String?
        let expansion = TreeExpansionState()
        
        await JSONViewerHelpers.handleParsingError(
            genericError,
            showError: { message in
                errorMessage = message
            },
            expansion: expansion
        )
        
        XCTAssertNotNil(errorMessage)
        XCTAssertTrue(errorMessage!.contains("Failed to parse JSON"))
        XCTAssertTrue(errorMessage!.contains("Generic error"))
    }
    
    func testHandleInvalidJSON() {
        let fileInfo = FileInfo(
            url: nil,
            name: "invalid.json",
            size: 100,
            modifiedDate: Date(),
            isValidJSON: false,
            errorMessage: "Invalid JSON format"
        )
        
        var errorMessage: String?
        let expansion = TreeExpansionState()
        
        JSONViewerHelpers.handleInvalidJSON(
            fileInfo: fileInfo,
            showError: { message in
                errorMessage = message
            },
            expansion: expansion
        )
        
        XCTAssertNotNil(errorMessage)
        XCTAssertEqual(errorMessage, "Invalid JSON format")
    }
    
    func testHandleInvalidJSONNoErrorMessage() {
        let fileInfo = FileInfo(
            url: nil,
            name: "invalid.json",
            size: 100,
            modifiedDate: Date(),
            isValidJSON: false,
            errorMessage: nil
        )
        
        var errorMessage: String?
        let expansion = TreeExpansionState()
        
        JSONViewerHelpers.handleInvalidJSON(
            fileInfo: fileInfo,
            showError: { message in
                errorMessage = message
            },
            expansion: expansion
        )
        
        // Should not call showError if no error message
        XCTAssertNil(errorMessage)
    }
    
    // MARK: - Window Frame Tracking Tests
    
    func testSetupWindowFrameTracking() {
        let settings = UserSettingsManager.shared
        let originalFrame = settings.windowFrame
        
        // This test mainly verifies that the function doesn't crash
        // In a real test environment, we might not have a window
        JSONViewerHelpers.setupWindowFrameTracking(settings: settings)
        
        // The frame should remain the same if no window is available
        XCTAssertEqual(settings.windowFrame, originalFrame)
    }
    
    // MARK: - Performance Tests
    
    func testCountNodesPerformance() {
        // Create a large tree for performance testing
        var children: [JSONNode] = []
        for i in 0..<10000 {
            let child = JSONNode(
                key: "child\(i)",
                value: .string("value\(i)"),
                children: [],
                path: "child\(i)"
            )
            children.append(child)
        }
        
        let node = JSONNode(
            key: "root",
            value: .object,
            children: children,
            path: ""
        )
        
        measure {
            _ = JSONViewerHelpers.countNodes(node)
        }
    }
    
    func testConvertTextToDataPerformance() async throws {
        let largeText = String(repeating: "This is a test string. ", count: 10000)
        
        measure {
            Task {
                _ = try await JSONViewerHelpers.convertTextToData(largeText)
            }
        }
    }
}
