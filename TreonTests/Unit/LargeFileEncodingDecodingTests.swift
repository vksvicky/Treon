import XCTest
import Foundation
@testable import Treon

@MainActor
final class LargeFileEncodingDecodingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Large File Encoding/Decoding Tests
    
    func testLargeFileEncodingDecoding_10MB() throws {
        let testData = createLargeJSONData(size: 10 * 1024 * 1024) // 10MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        // Test encoding
        let encodedData = try JSONEncoder().encode(result)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        // Test decoding
        let decodedTree = try JSONDecoder().decode(RustJSONTree.self, from: encodedData)
        
        // Verify roundtrip integrity
        XCTAssertEqual(result.totalNodes, decodedTree.totalNodes, "Node count should match after roundtrip")
        XCTAssertEqual(result.totalSizeBytes, decodedTree.totalSizeBytes, "Size should match after roundtrip")
        XCTAssertEqual(result.root.value, decodedTree.root.value, "Root value should match after roundtrip")
        XCTAssertEqual(result.root.children.count, decodedTree.root.children.count, "Root children count should match after roundtrip")
        
        print("✅ 10MB file encoding/decoding test passed - nodes: \(result.totalNodes), encoded size: \(encodedData.count) bytes")
    }
    
    func testLargeFileEncodingDecoding_50MB() throws {
        let testData = createLargeJSONData(size: 50 * 1024 * 1024) // 50MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        // Test encoding
        let encodedData = try JSONEncoder().encode(result)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        // Test decoding
        let decodedTree = try JSONDecoder().decode(RustJSONTree.self, from: encodedData)
        
        // Verify roundtrip integrity
        XCTAssertEqual(result.totalNodes, decodedTree.totalNodes, "Node count should match after roundtrip")
        XCTAssertEqual(result.totalSizeBytes, decodedTree.totalSizeBytes, "Size should match after roundtrip")
        XCTAssertEqual(result.root.value, decodedTree.root.value, "Root value should match after roundtrip")
        
        print("✅ 50MB file encoding/decoding test passed - nodes: \(result.totalNodes), encoded size: \(encodedData.count) bytes")
    }
    
    func testLargeFileEncodingDecoding_100MB() throws {
        let testData = createLargeJSONData(size: 100 * 1024 * 1024) // 100MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        // Test encoding
        let encodedData = try JSONEncoder().encode(result)
        XCTAssertGreaterThan(encodedData.count, 0, "Encoded data should not be empty")
        
        // Test decoding
        let decodedTree = try JSONDecoder().decode(RustJSONTree.self, from: encodedData)
        
        // Verify roundtrip integrity
        XCTAssertEqual(result.totalNodes, decodedTree.totalNodes, "Node count should match after roundtrip")
        XCTAssertEqual(result.totalSizeBytes, decodedTree.totalSizeBytes, "Size should match after roundtrip")
        XCTAssertEqual(result.root.value, decodedTree.root.value, "Root value should match after roundtrip")
        
        print("✅ 100MB file encoding/decoding test passed - nodes: \(result.totalNodes), encoded size: \(encodedData.count) bytes")
    }
    
    // MARK: - Large File Tree Display Tests
    
    func testLargeFileTreeDisplay_10MB() throws {
        let testData = createLargeJSONData(size: 10 * 1024 * 1024) // 10MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        // Test tree display properties
        XCTAssertEqual(result.root.key, "", "Root key should be empty string")
        XCTAssertEqual(result.root.path, "$", "Root path should be $")
        XCTAssertEqual(result.root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.root.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 10MB file tree display test passed - root children: \(result.root.children.count)")
    }
    
    func testLargeFileTreeDisplay_50MB() throws {
        let testData = createLargeJSONData(size: 50 * 1024 * 1024) // 50MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        // Test tree display properties
        XCTAssertEqual(result.root.key, "", "Root key should be empty string")
        XCTAssertEqual(result.root.path, "$", "Root path should be $")
        XCTAssertEqual(result.root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.root.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 50MB file tree display test passed - root children: \(result.root.children.count)")
    }
    
    func testLargeFileTreeDisplay_100MB() throws {
        let testData = createLargeJSONData(size: 100 * 1024 * 1024) // 100MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        // Test tree display properties
        XCTAssertEqual(result.root.key, "", "Root key should be empty string")
        XCTAssertEqual(result.root.path, "$", "Root path should be $")
        XCTAssertEqual(result.root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in result.root.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 100MB file tree display test passed - root children: \(result.root.children.count)")
    }
    
    // MARK: - Large File Swift Tree Builder Tests
    
    func testLargeFileSwiftTreeBuilder_10MB() throws {
        let testData = createLargeJSONData(size: 10 * 1024 * 1024) // 10MB
        let root = try JSONTreeBuilder.build(from: testData)
        
        // Test tree display properties
        XCTAssertEqual(root.key, nil, "Root key should be nil")
        XCTAssertEqual(root.path, "$", "Root path should be $")
        XCTAssertEqual(root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(root.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in root.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 10MB Swift tree builder test passed - root children: \(root.children.count)")
    }
    
    func testLargeFileSwiftTreeBuilder_50MB() throws {
        let testData = createLargeJSONData(size: 50 * 1024 * 1024) // 50MB
        let root = try JSONTreeBuilder.build(from: testData)
        
        // Test tree display properties
        XCTAssertEqual(root.key, nil, "Root key should be nil")
        XCTAssertEqual(root.path, "$", "Root path should be $")
        XCTAssertEqual(root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(root.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in root.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 50MB Swift tree builder test passed - root children: \(root.children.count)")
    }
    
    func testLargeFileSwiftTreeBuilder_100MB() throws {
        let testData = createLargeJSONData(size: 100 * 1024 * 1024) // 100MB
        let root = try JSONTreeBuilder.build(from: testData)
        
        // Test tree display properties
        XCTAssertEqual(root.key, nil, "Root key should be nil")
        XCTAssertEqual(root.path, "$", "Root path should be $")
        XCTAssertEqual(root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(root.children.count, 0, "Root should have children")
        
        // Test that children can be displayed
        for child in root.children {
            XCTAssertNotNil(child.key, "Child should have a key")
            XCTAssertNotNil(child.path, "Child should have a path")
            XCTAssertTrue(child.path.hasPrefix("$."), "Child path should start with $.")
        }
        
        print("✅ 100MB Swift tree builder test passed - root children: \(root.children.count)")
    }
    
    // MARK: - Performance Tests
    
    func testLargeFileProcessingPerformance() throws {
        let sizes = [
            (10 * 1024 * 1024, "10MB"),
            (50 * 1024 * 1024, "50MB"),
            (100 * 1024 * 1024, "100MB")
        ]
        
        for (size, description) in sizes {
            let testData = createLargeJSONData(size: size)
            
            // Test Rust backend performance
            let rustStartTime = CFAbsoluteTimeGetCurrent()
            let rustResult = try RustBackend.processData(testData, maxDepth: 0)
            let rustTime = CFAbsoluteTimeGetCurrent() - rustStartTime
            
            // Test Swift backend performance
            let swiftStartTime = CFAbsoluteTimeGetCurrent()
            let swiftResult = try JSONTreeBuilder.build(from: testData)
            let swiftTime = CFAbsoluteTimeGetCurrent() - swiftStartTime
            
            print("\(description) - Rust: \(String(format: "%.3f", rustTime))s, Swift: \(String(format: "%.3f", swiftTime))s")
            print("  Rust nodes: \(rustResult.totalNodes), Swift children: \(swiftResult.children.count)")
            
            // Both should complete successfully
            XCTAssertGreaterThan(rustResult.totalNodes, 0, "Rust should process \(description)")
            XCTAssertGreaterThan(swiftResult.children.count, 0, "Swift should process \(description)")
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
