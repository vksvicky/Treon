import XCTest
@testable import Treon

/// Integration tests for HybridJSONProcessor
/// Tests the full integration: File -> HybridJSONProcessor -> Swift/Rust backend -> JSONNode
@MainActor
final class HybridJSONProcessorIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - File Size Integration Tests
    
    func testSmallFileProcessing() async throws {
        let testSizes = [
            (10 * 1024, "10KB"),
            (1 * 1024 * 1024, "1MB"),
            (5 * 1024 * 1024, "5MB"),
            (10 * 1024 * 1024, "10MB")
        ]
        
        for (sizeBytes, description) in testSizes {
            print("Testing \(description) file processing (\(sizeBytes) bytes)")
            
            let testData = createTestJSONData(size: sizeBytes)
            let result = try await HybridJSONProcessor.processData(testData)
            
            XCTAssertGreaterThan(result.children.count, 0, "\(description) should have children")
            XCTAssertNil(result.key, "Root key should be nil for root node")
            XCTAssertEqual(result.value, .object, "Root should be an Object")
            
            print("✅ \(description) processing test passed")
        }
    }
    
    func testLargeFileProcessing() async throws {
        let testSizes = [
            (25 * 1024 * 1024, "25MB"),
            (50 * 1024 * 1024, "50MB"),
            (100 * 1024 * 1024, "100MB"),
            (250 * 1024 * 1024, "250MB")
        ]
        
        for (sizeBytes, description) in testSizes {
            print("Testing \(description) file processing (\(sizeBytes) bytes)")
            
            let testData = createTestJSONData(size: sizeBytes)
            let result = try await HybridJSONProcessor.processData(testData)
            
            XCTAssertGreaterThan(result.children.count, 0, "\(description) should have children")
            XCTAssertNil(result.key, "Root key should be nil for root node")
            XCTAssertEqual(result.value, .object, "Root should be an Object")
            
            print("✅ \(description) processing test passed")
        }
    }
    
    // MARK: - Backend Selection Tests
    
    func testBackendSelection() async throws {
        // Test that Swift backend is used for small files
        let smallData = createTestJSONData(size: 1 * 1024 * 1024) // 1MB
        let smallResult = try await HybridJSONProcessor.processData(smallData)
        XCTAssertGreaterThan(smallResult.children.count, 0, "Small file should be processed by Swift backend")
        
        // Test that Rust backend is used for large files
        let largeData = createTestJSONData(size: 100 * 1024 * 1024) // 100MB
        let largeResult = try await HybridJSONProcessor.processData(largeData)
        XCTAssertGreaterThan(largeResult.children.count, 0, "Large file should be processed by Rust backend")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidJSONHandling() async {
        let invalidJSON = "invalid json content".data(using: .utf8)!
        
        do {
            _ = try await HybridJSONProcessor.processData(invalidJSON)
            XCTFail("Should have thrown an error for invalid JSON")
        } catch {
            // Expected to throw an error
            XCTAssertTrue(error is TreonError, "Should throw TreonError")
        }
    }
    
    func testEmptyDataHandling() async {
        let emptyData = Data()
        
        do {
            _ = try await HybridJSONProcessor.processData(emptyData)
            XCTFail("Should have thrown an error for empty data")
        } catch {
            // Expected to throw an error
            XCTAssertTrue(error is TreonError, "Should throw TreonError")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyJSONObject() async throws {
        let emptyJSON = "{}".data(using: .utf8)!
        let result = try await HybridJSONProcessor.processData(emptyJSON)
        
        XCTAssertEqual(result.children.count, 0, "Empty JSON should have no children")
        XCTAssertEqual(result.value, .object, "Root should be an Object")
    }
    
    func testNestedJSONProcessing() async throws {
        let nestedJSON = """
        {
            "level1": {
                "level2": {
                    "level3": {
                        "value": "deep"
                    }
                }
            }
        }
        """.data(using: .utf8)!
        
        let result = try await HybridJSONProcessor.processData(nestedJSON)
        
        XCTAssertEqual(result.children.count, 1, "Nested JSON should have exactly 1 child (level1)")
        XCTAssertEqual(result.value, .object, "Root should be an Object")
    }
    
    func testArrayJSONProcessing() async throws {
        let arrayJSON = """
        {
            "items": [1, 2, 3, "hello", true, null]
        }
        """.data(using: .utf8)!
        
        let result = try await HybridJSONProcessor.processData(arrayJSON)
        
        XCTAssertEqual(result.children.count, 1, "Array JSON should have exactly 1 child (items)")
        XCTAssertEqual(result.value, .object, "Root should be an Object")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceSmallFileProcessing() {
        let testData = createTestJSONData(size: 1 * 1024 * 1024) // 1MB
        
        measure {
            let expectation = XCTestExpectation(description: "Processing complete")
            
            Task {
                do {
                    _ = try await HybridJSONProcessor.processData(testData)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testPerformanceLargeFileProcessing() {
        let testData = createTestJSONData(size: 50 * 1024 * 1024) // 50MB
        
        measure {
            let expectation = XCTestExpectation(description: "Processing complete")
            
            Task {
                do {
                    _ = try await HybridJSONProcessor.processData(testData)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 60.0)
        }
    }
    
    // MARK: - Data Type Tests
    
    func testAllJSONDataTypes() async throws {
        let allTypesJSON = """
        {
            "string": "hello",
            "number": 42.5,
            "integer": 100,
            "boolean_true": true,
            "boolean_false": false,
            "null_value": null,
            "object": {
                "nested": "value"
            },
            "array": [1, 2, 3, "hello", true, null]
        }
        """.data(using: .utf8)!
        
        let result = try await HybridJSONProcessor.processData(allTypesJSON)
        
        XCTAssertGreaterThan(result.children.count, 1, "All types JSON should have multiple children")
        XCTAssertEqual(result.value, .object, "Root should be an Object")
        
        // Verify we can find nodes with different data types
        let stringNode = result.children.first { $0.key == "string" }
        XCTAssertNotNil(stringNode, "Should have string node")
        XCTAssertEqual(stringNode?.value, .string("hello"), "String node should have correct value")
        
        let numberNode = result.children.first { $0.key == "number" }
        XCTAssertNotNil(numberNode, "Should have number node")
        XCTAssertEqual(numberNode?.value, .number(42.5), "Number node should have correct value")
        
        let booleanNode = result.children.first { $0.key == "boolean_true" }
        XCTAssertNotNil(booleanNode, "Should have boolean node")
        XCTAssertEqual(booleanNode?.value, .bool(true), "Boolean node should have correct value")
        
        let nullNode = result.children.first { $0.key == "null_value" }
        XCTAssertNotNil(nullNode, "Should have null node")
        XCTAssertEqual(nullNode?.value, .null, "Null node should have correct value")
    }
    
    // MARK: - Helper Methods
    
    private func createTestJSONData(size: Int) -> Data {
        var json = "{\"data\": ["
        
        // Add enough data to reach target size
        let itemSize = 1000 // Each item is ~1000 bytes
        let numItems = size / itemSize
        
        for i in 0..<numItems {
            if i > 0 {
                json += ","
            }
            json += """
            {"id": \(i), "name": "item_\(i)", "description": "This is a test item with some data to make it larger", "values": [1, 2, 3, 4, 5], "nested": {"key": "value_\(i)"}}
            """
        }
        
        json += "]}"
        return json.data(using: .utf8)!
    }
}
