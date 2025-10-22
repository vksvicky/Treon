import XCTest
@testable import Treon

final class RustBackendTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for tests
        RustBackend.initialize()
    }
    
    // MARK: - Initialization Tests
    
    func testRustBackendInitialization() {
        // Test that initialization doesn't crash
        RustBackend.initialize()
        // If we get here, initialization was successful
        XCTAssertTrue(true)
    }
    
    // MARK: - Data Processing Tests
    
    func testProcessSimpleJSONData() {
        let expectation = XCTestExpectation(description: "Process simple JSON data")
        
        let jsonData = """
        {
            "name": "test",
            "value": 42,
            "active": true
        }
        """.data(using: .utf8)!
        
        Task {
            do {
                let result = try await RustBackend.processData(jsonData)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.root.key, "")
                XCTAssertEqual(result.root.path, "$")
                XCTAssertEqual(result.totalNodes, 4) // root + 3 children
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process JSON data: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProcessArrayJSONData() {
        let expectation = XCTestExpectation(description: "Process array JSON data")
        
        let jsonData = """
        [1, 2, 3, {"nested": "value"}]
        """.data(using: .utf8)!
        
        Task {
            do {
                let result = try await RustBackend.processData(jsonData)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.root.value, .array)
                XCTAssertEqual(result.root.children.count, 4)
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process array JSON data: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProcessNestedJSONData() {
        let expectation = XCTestExpectation(description: "Process nested JSON data")
        
        let jsonData = """
        {
            "user": {
                "name": "John",
                "age": 30,
                "address": {
                    "street": "123 Main St",
                    "city": "New York"
                }
            },
            "items": [1, 2, 3]
        }
        """.data(using: .utf8)!
        
        Task {
            do {
                let result = try await RustBackend.processData(jsonData)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.root.children.count, 2) // user, items
                
                // Check nested structure
                let userNode = result.root.children.first { $0.key == "user" }
                XCTAssertNotNil(userNode)
                XCTAssertEqual(userNode?.value, .object)
                XCTAssertEqual(userNode?.children.count, 3) // name, age, address
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process nested JSON data: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testProcessInvalidJSON() {
        let expectation = XCTestExpectation(description: "Handle invalid JSON")
        
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        
        Task {
            do {
                _ = try await RustBackend.processData(invalidJSON)
                XCTFail("Should have thrown an error for invalid JSON")
            } catch {
                // Expected to fail
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProcessEmptyData() {
        let expectation = XCTestExpectation(description: "Handle empty data")
        
        let emptyData = Data()
        
        Task {
            do {
                _ = try await RustBackend.processData(emptyData)
                XCTFail("Should have thrown an error for empty data")
            } catch {
                // Expected to fail
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Statistics Tests
    
    func testGetStats() {
        let stats = RustBackend.getStats()
        XCTAssertNotNil(stats)
        
        if let stats = stats {
            XCTAssertEqual(stats.backend, "rust")
            XCTAssertFalse(stats.version.isEmpty)
            XCTAssertFalse(stats.features.isEmpty)
            XCTAssertTrue(stats.features.contains("simd-json"))
            XCTAssertTrue(stats.features.contains("streaming"))
            XCTAssertTrue(stats.features.contains("async"))
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeData() {
        let expectation = XCTestExpectation(description: "Process large JSON data")
        
        // Create a large JSON structure
        var largeJSON = """
        {
            "users": [
        """
        
        // Add many users to make it large
        for i in 0..<1000 {
            largeJSON += """
                {
                    "id": \(i),
                    "name": "User \(i)",
                    "email": "user\(i)@example.com"
                }
            """
            if i < 999 {
                largeJSON += ","
            }
        }
        
        largeJSON += """
            ]
        }
        """
        
        let jsonData = largeJSON.data(using: .utf8)!
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        Task {
            do {
                let result = try await RustBackend.processData(jsonData)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                XCTAssertNotNil(result)
                XCTAssertLessThan(processingTime, 1.0, "Processing should be fast (< 1 second)")
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process large JSON data: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Data Structure Tests
    
    func testRustJSONValueTypes() {
        // Test string value
        let stringValue = RustJSONValue.string("test")
        XCTAssertEqual(stringValue.displayName, "String")
        XCTAssertEqual(stringValue.displayNameWithCount(5), "String")
        
        // Test number value
        let numberValue = RustJSONValue.number(42.0)
        XCTAssertEqual(numberValue.displayName, "Number")
        
        // Test boolean value
        let boolValue = RustJSONValue.boolean(true)
        XCTAssertEqual(boolValue.displayName, "Boolean")
        
        // Test null value
        let nullValue = RustJSONValue.null
        XCTAssertEqual(nullValue.displayName, "null")
        
        // Test object value
        let objectValue = RustJSONValue.object
        XCTAssertEqual(objectValue.displayName, "Object")
        XCTAssertEqual(objectValue.displayNameWithCount(10), "Object{10}")
        
        // Test array value
        let arrayValue = RustJSONValue.array
        XCTAssertEqual(arrayValue.displayName, "Array")
        XCTAssertEqual(arrayValue.displayNameWithCount(5), "Array[5]")
    }
    
    func testRustNodeMetadata() {
        let metadata = RustNodeMetadata(
            sizeBytes: 1024,
            depth: 2,
            descendantCount: 5,
            streamed: true,
            processingTimeMs: 100
        )
        
        XCTAssertEqual(metadata.sizeBytes, 1024)
        XCTAssertEqual(metadata.depth, 2)
        XCTAssertEqual(metadata.descendantCount, 5)
        XCTAssertTrue(metadata.streamed)
        XCTAssertEqual(metadata.processingTimeMs, 100)
    }
    
    func testRustProcessingStats() {
        let stats = RustProcessingStats(
            processingTimeMs: 1000,
            parsingTimeMs: 500,
            treeBuildingTimeMs: 500,
            peakMemoryBytes: 1024 * 1024,
            usedStreaming: true,
            streamingChunks: 10
        )
        
        XCTAssertEqual(stats.processingTimeMs, 1000)
        XCTAssertEqual(stats.parsingTimeMs, 500)
        XCTAssertEqual(stats.treeBuildingTimeMs, 500)
        XCTAssertEqual(stats.peakMemoryBytes, 1024 * 1024)
        XCTAssertTrue(stats.usedStreaming)
        XCTAssertEqual(stats.streamingChunks, 10)
    }
}
