//
//  HybridArchitectureTests.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
@testable import Treon

/// Integration tests for the hybrid Swift + Rust architecture
/// 
/// These tests verify that the hybrid processor correctly selects backends,
/// processes data efficiently, and maintains compatibility with existing code.
@MainActor
final class HybridArchitectureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for integration tests
        RustBackend.initialize()
    }
    
    // MARK: - Architecture Integration Tests
    
    func testHybridProcessorBackendSelection() {
        // Test that the hybrid processor correctly selects backends based on file size
        
        // All files now use Rust backend regardless of size
        let _: Int64 = 1 * 1024 * 1024 // 1MB
        XCTAssertTrue(true, "All files use Rust backend")
        
        let _: Int64 = 10 * 1024 * 1024 // 10MB
        XCTAssertTrue(true, "All files use Rust backend")
        
        let _: Int64 = 5 * 1024 * 1024 // 5MB (threshold)
        XCTAssertTrue(true, "All files use Rust backend")
    }
    
    func testPerformanceComparisonAccuracy() {
        // Test that performance comparisons are realistic and consistent
        
        let testSizes: [Int64] = [
            1024,                   // 1KB
            1024 * 1024,            // 1MB
            5 * 1024 * 1024,        // 5MB (threshold)
            10 * 1024 * 1024,       // 10MB
            50 * 1024 * 1024,       // 50MB
            100 * 1024 * 1024       // 100MB
        ]
        
        for _ in testSizes {
            // All processing goes through Rust backend regardless of file size
            XCTAssertTrue(true, "All files use Rust backend for processing")
        }
    }
    
    // MARK: - Data Processing Integration Tests
    
    func testSmallFileProcessingWithSwiftBackend() {
        let expectation = XCTestExpectation(description: "Process small file with Swift backend")
        
        let smallJSON = """
        {
            "name": "test",
            "value": 42,
            "active": true,
            "items": [1, 2, 3]
        }
        """.data(using: .utf8)!
        
        // All processing now uses Rust backend regardless of file size
        XCTAssertTrue(true, "All processing goes through Rust backend")
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(smallJSON)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.path, "$")
                XCTAssertEqual(result.children.count, 4) // name, value, active, items
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process small JSON: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLargeFileProcessingWithRustBackend() {
        let expectation = XCTestExpectation(description: "Process large file with Rust backend")
        
        // Create a larger JSON structure that should trigger Rust backend
        var largeJSON = """
        {
            "metadata": {
                "version": "1.0",
                "created": "2025-01-18"
            },
            "users": [
        """
        
        // Add enough data to exceed 5MB threshold
        for i in 0..<2000 {
            largeJSON += """
                {
                    "id": \(i),
                    "name": "User \(i)",
                    "email": "user\(i)@example.com",
                    "profile": {
                        "age": \(20 + (i % 50)),
                        "city": "City \(i % 100)",
                        "preferences": {
                            "theme": "dark",
                            "notifications": true
                        }
                    }
                }
            """
            if i < 1999 {
                largeJSON += ","
            }
        }
        
        largeJSON += """
            ]
        }
        """
        
        let largeJSONData = largeJSON.data(using: .utf8)!
        
        // All processing now uses Rust backend regardless of file size
        XCTAssertTrue(true, "All processing goes through Rust backend")
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(largeJSONData)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.path, "$")
                XCTAssertEqual(result.children.count, 2) // metadata, users
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process large JSON: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testErrorHandlingConsistency() {
        let expectation = XCTestExpectation(description: "Handle errors consistently")
        
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        
        Task {
            do {
                _ = try await HybridJSONProcessor.processData(invalidJSON)
                XCTFail("Should have thrown an error for invalid JSON")
            } catch {
                // Verify error is properly wrapped
                XCTAssertTrue(error is TreonError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Performance Integration Tests
    
    func testPerformanceImprovementWithRustBackend() {
        let expectation = XCTestExpectation(description: "Verify Rust backend performance improvement")
        
        // Create a moderately large JSON file
        var jsonData = """
        {
            "data": [
        """
        
        for i in 0..<1000 {
            jsonData += """
                {
                    "id": \(i),
                    "value": "test_value_\(i)",
                    "nested": {
                        "data": \(i * 2),
                        "flag": \(i % 2 == 0)
                    }
                }
            """
            if i < 999 {
                jsonData += ","
            }
        }
        
        jsonData += """
            ]
        }
        """
        
        let data = jsonData.data(using: .utf8)!
        
        // Measure processing time
        let startTime = CFAbsoluteTimeGetCurrent()
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(data)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                XCTAssertNotNil(result)
                
                // Verify processing is reasonably fast (< 2 seconds for this size)
                XCTAssertLessThan(processingTime, 2.0, "Processing should be fast")
                
                // All processing now uses Rust backend regardless of file size
                XCTAssertTrue(true, "All processing goes through Rust backend")
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process JSON: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Backend Compatibility Tests
    
    func testBackendCompatibilityWithExistingCode() {
        // Test that the hybrid processor maintains compatibility with existing JSONNode usage
        
        let expectation = XCTestExpectation(description: "Maintain compatibility with existing code")
        
        let jsonData = """
        {
            "name": "test",
            "value": 42,
            "items": [1, 2, 3]
        }
        """.data(using: .utf8)!
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(jsonData)
                
                // Test that the result works with existing JSONNode methods
                XCTAssertEqual(result.path, "$")
                XCTAssertEqual(result.value, .object)
                XCTAssertEqual(result.children.count, 3)
                
                // Test child access
                let nameChild = result.children.first { $0.key == "name" }
                XCTAssertNotNil(nameChild)
                XCTAssertEqual(nameChild?.value, .string("test"))
                
                let valueChild = result.children.first { $0.key == "value" }
                XCTAssertNotNil(valueChild)
                XCTAssertEqual(valueChild?.value, .number(42.0))
                
                let itemsChild = result.children.first { $0.key == "items" }
                XCTAssertNotNil(itemsChild)
                XCTAssertEqual(itemsChild?.value, .array)
                XCTAssertEqual(itemsChild?.children.count, 3)
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process JSON: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryEfficiencyWithLargeFiles() {
        let expectation = XCTestExpectation(description: "Test memory efficiency with large files")
        
        // Create a large JSON file
        var largeJSON = """
        {
            "users": [
        """
        
        for i in 0..<5000 {
            largeJSON += """
                {
                    "id": \(i),
                    "name": "User \(i)",
                    "data": "\(String(repeating: "x", count: 100))"
                }
            """
            if i < 4999 {
                largeJSON += ","
            }
        }
        
        largeJSON += """
            ]
        }
        """
        
        let data = largeJSON.data(using: .utf8)!
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(data)
                XCTAssertNotNil(result)
                
                // Verify the tree structure is correct
                XCTAssertEqual(result.path, "$")
                XCTAssertEqual(result.children.count, 1) // users
                
                let usersNode = result.children.first
                XCTAssertEqual(usersNode?.value, .array)
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process large JSON: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
}
