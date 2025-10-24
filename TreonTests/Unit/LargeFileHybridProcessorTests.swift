import XCTest
import Foundation
@testable import Treon

@MainActor
final class LargeFileHybridProcessorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Large File Hybrid Processing Tests
    
    func testHybridProcessorLargeFile_10MB() async throws {
        let testData = createLargeJSONData(size: 10 * 1024 * 1024) // 10MB
        let result = try await HybridJSONProcessor.processData(testData)
        
        // Test that the result is valid
        XCTAssertEqual(result.path, "$", "Root path should be $")
        XCTAssertEqual(result.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 10MB HybridJSONProcessor test passed - root children: \(result.children.count)")
    }
    
    func testHybridProcessorLargeFile_50MB() async throws {
        let testData = createLargeJSONData(size: 50 * 1024 * 1024) // 50MB
        let result = try await HybridJSONProcessor.processData(testData)
        
        // Test that the result is valid
        XCTAssertEqual(result.path, "$", "Root path should be $")
        XCTAssertEqual(result.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 50MB HybridJSONProcessor test passed - root children: \(result.children.count)")
    }
    
    func testHybridProcessorLargeFile_100MB() async throws {
        let testData = createLargeJSONData(size: 100 * 1024 * 1024) // 100MB
        let result = try await HybridJSONProcessor.processData(testData)
        
        // Test that the result is valid
        XCTAssertEqual(result.path, "$", "Root path should be $")
        XCTAssertEqual(result.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 100MB HybridJSONProcessor test passed - root children: \(result.children.count)")
    }
    
    // MARK: - Large File Tree Display Tests
    
    func testLargeFileTreeDisplay_10MB() async throws {
        let testData = createLargeJSONData(size: 10 * 1024 * 1024) // 10MB
        let result = try await HybridJSONProcessor.processData(testData)
        
        // Test tree display properties
        XCTAssertEqual(result.key, nil, "Root key should be nil")
        XCTAssertEqual(result.path, "$", "Root path should be $")
        XCTAssertEqual(result.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 10MB tree display test passed - root children: \(result.children.count)")
    }
    
    func testLargeFileTreeDisplay_50MB() async throws {
        let testData = createLargeJSONData(size: 50 * 1024 * 1024) // 50MB
        let result = try await HybridJSONProcessor.processData(testData)
        
        // Test tree display properties
        XCTAssertEqual(result.key, nil, "Root key should be nil")
        XCTAssertEqual(result.path, "$", "Root path should be $")
        XCTAssertEqual(result.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 50MB tree display test passed - root children: \(result.children.count)")
    }
    
    func testLargeFileTreeDisplay_100MB() async throws {
        let testData = createLargeJSONData(size: 100 * 1024 * 1024) // 100MB
        let result = try await HybridJSONProcessor.processData(testData)
        
        // Test tree display properties
        XCTAssertEqual(result.key, nil, "Root key should be nil")
        XCTAssertEqual(result.path, "$", "Root path should be $")
        XCTAssertEqual(result.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 100MB tree display test passed - root children: \(result.children.count)")
    }
    
    // MARK: - Performance Tests
    
    func testLargeFileProcessingPerformance() async throws {
        let sizes = [
            (10 * 1024 * 1024, "10MB"),
            (50 * 1024 * 1024, "50MB"),
            (100 * 1024 * 1024, "100MB")
        ]
        
        for (size, description) in sizes {
            let testData = createLargeJSONData(size: size)
            
            // Test HybridJSONProcessor performance
            let startTime = CFAbsoluteTimeGetCurrent()
            let result = try await HybridJSONProcessor.processData(testData)
            let time = CFAbsoluteTimeGetCurrent() - startTime
            
            print("\(description) - HybridJSONProcessor: \(String(format: "%.3f", time))s")
            print("  Children: \(result.children.count)")
            
            // Should complete successfully
            XCTAssertGreaterThan(result.children.count, 0, "HybridJSONProcessor should process \(description)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testLargeFileErrorHandling() async throws {
        // Test with invalid JSON
        let invalidJSON = String(repeating: "{", count: 1000).data(using: .utf8)!
        
        do {
            _ = try await HybridJSONProcessor.processData(invalidJSON)
            XCTFail("Should have thrown an error for invalid JSON")
        } catch {
            // Expected error
            print("✅ Invalid JSON correctly rejected: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    
    private func createLargeJSONData(size: Int) -> Data {
        var json = "{\n"
        var current = 2
        var index = 0
        var isFirstEntry = true
        
        while current < size {
            let key = "key_\(index)"
            let remaining = max(0, size - current - 100)
            let value = String(repeating: "x", count: min(1024, remaining))
            
            if !isFirstEntry {
                json += ",\n"
                current += 2
            }
            
            json += "  \"\(key)\": \"\(value)\""
            current += key.count + value.count + 8
            
            isFirstEntry = false
            index += 1
        }
        
        json += "\n}"
        return json.data(using: .utf8)!
    }
}
