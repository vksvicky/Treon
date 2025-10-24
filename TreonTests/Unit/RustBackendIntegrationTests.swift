import XCTest
@testable import Treon

/// Comprehensive integration tests for Rust backend
/// Tests the full roundtrip: Swift -> Rust FFI -> JSON string -> Swift decode
@MainActor
final class RustBackendIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - File Size Tests
    
    func testSmallFileSizes() throws {
        let testSizes = [
            (10 * 1024, "10KB"),
            (1 * 1024 * 1024, "1MB"),
            (5 * 1024 * 1024, "5MB"),
            (10 * 1024 * 1024, "10MB")
        ]
        
        for (targetSizeBytes, description) in testSizes {
            print("Testing \(description) file (target: \(targetSizeBytes) bytes)")
            
            let testData = createTestJSONData(size: targetSizeBytes)
            let actualSizeBytes = testData.count
            print("Actual data size: \(actualSizeBytes) bytes")
            
            let result = try RustBackend.processData(testData, maxDepth: 0)
            
            XCTAssertGreaterThan(result.totalNodes, 0, "\(description) should have nodes")
            XCTAssertEqual(result.totalSizeBytes, actualSizeBytes, "\(description) size should match actual data size")
            XCTAssertEqual(result.root.key, "", "Root key should be empty string")
            XCTAssertEqual(result.root.value, .object, "Root should be an Object")
            
            print("✅ \(description) test passed - nodes: \(result.totalNodes), size: \(result.totalSizeBytes)")
        }
    }
    
    func testLargeFileSizes() throws {
        let testSizes = [
            (25 * 1024 * 1024, "25MB"),
            (50 * 1024 * 1024, "50MB"),
            (100 * 1024 * 1024, "100MB"),
            (250 * 1024 * 1024, "250MB"),
            (500 * 1024 * 1024, "500MB"),
            (1 * 1024 * 1024 * 1024, "1GB")
        ]
        
        for (targetSizeBytes, description) in testSizes {
            print("Testing \(description) file (target: \(targetSizeBytes) bytes)")
            
            let testData = createTestJSONData(size: targetSizeBytes)
            let actualSizeBytes = testData.count
            print("Actual data size: \(actualSizeBytes) bytes")
            
            let result = try RustBackend.processData(testData, maxDepth: 0)
            
            XCTAssertGreaterThan(result.totalNodes, 0, "\(description) should have nodes")
            XCTAssertEqual(result.totalSizeBytes, actualSizeBytes, "\(description) size should match actual data size")
            XCTAssertEqual(result.root.key, "", "Root key should be empty string")
            XCTAssertEqual(result.root.value, .object, "Root should be an Object")
            
            print("✅ \(description) test passed - nodes: \(result.totalNodes), size: \(result.totalSizeBytes)")
        }
    }
    
    // MARK: - RustJSONValue Tests
    
    func testRustJSONValueDecoding() throws {
        // Test that all RustJSONValue variants decode correctly
        let testCases: [(String, RustJSONValue)] = [
            ("\"hello\"", .string("hello")),
            ("42.5", .number(42.5)),
            ("true", .boolean(true)),
            ("false", .boolean(false)),
            ("null", .null),
            ("\"Object\"", .object),
            ("\"Array\"", .array)
        ]
        
        for (jsonString, expectedValue) in testCases {
            let data = jsonString.data(using: .utf8)!
            let decodedValue = try JSONDecoder().decode(RustJSONValue.self, from: data)
            XCTAssertEqual(decodedValue, expectedValue, "Failed to decode \(jsonString)")
        }
    }
    
    func testRustJSONValueEncoding() throws {
        // Test that all RustJSONValue variants encode correctly
        let testCases: [RustJSONValue] = [
            .string("hello"),
            .number(42.5),
            .boolean(true),
            .boolean(false),
            .null,
            .object,
            .array
        ]
        
        for value in testCases {
            let encodedData = try JSONEncoder().encode(value)
            let encodedString = String(data: encodedData, encoding: .utf8)!
            
            // Test that we can decode it back
            let decodedData = encodedString.data(using: .utf8)!
            let decodedValue = try JSONDecoder().decode(RustJSONValue.self, from: decodedData)
            
            XCTAssertEqual(decodedValue, value, "Failed to roundtrip encode/decode \(value)")
            print("✅ \(value) encodes to: \(encodedString)")
        }
    }
    
    // MARK: - RustJSONTree Tests
    
    func testRustJSONTreeSerialization() throws {
        // Test serialization by creating a tree through the Rust backend
        let testJSON = """
        {
            "string_field": "hello",
            "number_field": 42,
            "boolean_field": true
        }
        """.data(using: .utf8)!
        
        let result = try RustBackend.processData(testJSON, maxDepth: 0)
        
        // Test serialization roundtrip
        let encodedData = try JSONEncoder().encode(result)
        let decodedTree = try JSONDecoder().decode(RustJSONTree.self, from: encodedData)
        
        XCTAssertEqual(result.root.value, decodedTree.root.value)
        XCTAssertEqual(result.totalNodes, decodedTree.totalNodes)
        XCTAssertEqual(result.totalSizeBytes, decodedTree.totalSizeBytes)
        XCTAssertEqual(result.root.children.count, decodedTree.root.children.count)
        
        print("✅ Tree serialization test passed - nodes: \(result.totalNodes), size: \(result.totalSizeBytes)")
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyJSON() throws {
        let emptyJSON = "{}".data(using: .utf8)!
        let result = try RustBackend.processData(emptyJSON, maxDepth: 0)
        
        XCTAssertEqual(result.totalNodes, 1, "Empty JSON should have 1 node (root)")
        XCTAssertEqual(result.root.value, .object, "Root should be an Object")
        XCTAssertEqual(result.root.children.count, 0, "Empty JSON should have no children")
    }
    
    func testNestedJSON() throws {
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
        
        let result = try RustBackend.processData(nestedJSON, maxDepth: 0)
        
        XCTAssertGreaterThan(result.totalNodes, 1, "Nested JSON should have multiple nodes")
        XCTAssertEqual(result.root.value, .object, "Root should be an Object")
    }
    
    func testArrayJSON() throws {
        let arrayJSON = """
        {
            "items": [1, 2, 3, "hello", true, null]
        }
        """.data(using: .utf8)!
        
        let result = try RustBackend.processData(arrayJSON, maxDepth: 0)
        
        XCTAssertGreaterThan(result.totalNodes, 1, "Array JSON should have multiple nodes")
        XCTAssertEqual(result.root.value, .object, "Root should be an Object")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceSmallFiles() {
        let testData = createTestJSONData(size: 1 * 1024 * 1024) // 1MB
        
        measure {
            do {
                _ = try RustBackend.processData(testData, maxDepth: 0)
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }
    }
    
    func testPerformanceLargeFiles() {
        let testData = createTestJSONData(size: 50 * 1024 * 1024) // 50MB
        
        measure {
            do {
                _ = try RustBackend.processData(testData, maxDepth: 0)
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }
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
