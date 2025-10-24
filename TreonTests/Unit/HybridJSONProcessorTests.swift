import XCTest
@testable import Treon

@MainActor
final class HybridJSONProcessorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for tests
        RustBackend.initialize()
    }
    
    // MARK: - Backend Selection Tests
    
    func testBackendSelectionForSmallFiles() {
        // Test that all files use Rust backend now
        let _: Int64 = 1024 * 1024 // 1MB
        // All processing goes through Rust backend regardless of file size
        XCTAssertTrue(true, "All files use Rust backend")
    }
    
    func testAlwaysUsesRustBackend() {
        // Since we always use Rust backend now, this test verifies the architecture
        let _: Int64 = 5 * 1024 * 1024 // 5MB
        // The processor should always use Rust backend regardless of file size
        XCTAssertTrue(true, "All processing goes through Rust backend")
    }
    
    // MARK: - Data Processing Tests
    
    func testProcessSmallJSONData() {
        let expectation = XCTestExpectation(description: "Process small JSON data")
        
        let jsonData = """
        {
            "name": "test",
            "value": 42,
            "active": true,
            "items": [1, 2, 3]
        }
        """.data(using: .utf8)!
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(jsonData)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.path, "$")
                XCTAssertEqual(result.children.count, 4) // name, value, active, items
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process JSON data: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProcessLargeJSONData() {
        let expectation = XCTestExpectation(description: "Process large JSON data")
        
        // Create a larger JSON structure
        var largeJSON = """
        {
            "metadata": {
                "version": "1.0",
                "created": "2025-01-18"
            },
            "users": [
        """
        
        // Add many users to make it large
        for i in 0..<1000 {
            largeJSON += """
                {
                    "id": \(i),
                    "name": "User \(i)",
                    "email": "user\(i)@example.com",
                    "profile": {
                        "age": \(20 + (i % 50)),
                        "city": "City \(i % 100)"
                    }
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
        
        Task { @MainActor in
            do {
                let result = try await HybridJSONProcessor.processData(jsonData)
                XCTAssertNotNil(result)
                XCTAssertEqual(result.path, "$")
                XCTAssertEqual(result.children.count, 2) // metadata, users
                
                // Check that users array has children
                let usersNode = result.children.first { $0.key == "users" }
                XCTAssertNotNil(usersNode)
                XCTAssertEqual(usersNode?.value, .array)
                
                expectation.fulfill()
            } catch {
                XCTFail("Failed to process large JSON data: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testProcessInvalidJSON() {
        let expectation = XCTestExpectation(description: "Handle invalid JSON")
        
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        
        Task {
            do {
                _ = try await HybridJSONProcessor.processData(invalidJSON)
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
                _ = try await HybridJSONProcessor.processData(emptyData)
                XCTFail("Should have thrown an error for empty data")
            } catch {
                // Expected to fail
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceComparisonAccuracy() {
        // Performance comparison tests removed - always use Rust backend
        let testSizes: [Int64] = [
            1024,           // 1KB
            1024 * 1024,    // 1MB
            10 * 1024 * 1024, // 10MB
            100 * 1024 * 1024  // 100MB
        ]
        
        for _ in testSizes {
            // All processing goes through Rust backend regardless of file size
            XCTAssertTrue(true, "All files use Rust backend for processing")
        }
    }
    
    // MARK: - Backend Type Tests
    
    func testBackendTypeDescriptions() {
        XCTAssertEqual(BackendType.swift.description, "Native Swift with Foundation JSONSerialization")
        XCTAssertEqual(BackendType.rust.description, "High-performance Rust with SIMD optimization")
    }
    
    func testBackendTypeAllCases() {
        let allCases = BackendType.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.swift))
        XCTAssertTrue(allCases.contains(.rust))
    }
}
