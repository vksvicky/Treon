import XCTest
import Foundation
@testable import Treon

@MainActor
final class RustBackendDebugTests: XCTestCase {
    
    func testRustBackendInitialization() throws {
        // Test that Rust backend can be initialized
        RustBackend.initialize()
        XCTAssertTrue(true, "Rust backend initialization should not crash")
    }
    
    func testRustBackendSmallFile() throws {
        // Test with a very small JSON file
        let smallJSON = """
        {
            "name": "test",
            "value": 42
        }
        """.data(using: .utf8)!
        
        let result = try RustBackend.processData(smallJSON, maxDepth: 0)
        
        XCTAssertEqual(result.root.key, "", "Root key should be empty string")
        XCTAssertEqual(result.root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
        
        print("✅ Small file test passed - nodes: \(result.totalNodes)")
    }
    
    func testRustBackendMediumFile() throws {
        // Test with a medium JSON file (1MB)
        let testData = createTestJSONData(size: 1024 * 1024) // 1MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        XCTAssertEqual(result.root.key, "", "Root key should be empty string")
        XCTAssertEqual(result.root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
        
        print("✅ Medium file test passed - nodes: \(result.totalNodes)")
    }
    
    func testRustBackendLargeFile() throws {
        // Test with a large JSON file (10MB)
        let testData = createTestJSONData(size: 10 * 1024 * 1024) // 10MB
        let result = try RustBackend.processData(testData, maxDepth: 0)
        
        XCTAssertEqual(result.root.key, "", "Root key should be empty string")
        XCTAssertEqual(result.root.value, .object, "Root should be an object")
        XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
        
        print("✅ Large file test passed - nodes: \(result.totalNodes)")
    }
    
    // MARK: - Helper Functions
    
    private func createTestJSONData(size: Int) -> Data {
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
