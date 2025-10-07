import XCTest
import SwiftUI
@testable import Treon

final class JSONTreeDisplayTests: XCTestCase {
    
    // MARK: - Node Display Tests
    
    func testNodeRowTitleForRootNode() throws {
        let data = try XCTUnwrap("{\"name\": \"John\"}".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Root node should display as "Root" or similar, not "$"
        let nodeRow = NodeRow(node: root)
        XCTAssertNotEqual(nodeRow.title, "$", "Root node should not display as '$'")
        XCTAssertTrue(nodeRow.title.contains("Root") || nodeRow.title.contains("Object"), "Root node should indicate it's the root or an object")
    }
    
    func testNodeRowTitleForObjectKeys() throws {
        let data = try XCTUnwrap("{\"name\": \"John\", \"age\": 30}".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Object keys should be displayed properly
        let nameNode = root.children.first { $0.key == "name" }
        let ageNode = root.children.first { $0.key == "age" }
        
        XCTAssertNotNil(nameNode)
        XCTAssertNotNil(ageNode)
        
        let nameRow = NodeRow(node: nameNode!)
        let ageRow = NodeRow(node: ageNode!)
        
        XCTAssertEqual(nameRow.title, "name", "Object key should be displayed correctly")
        XCTAssertEqual(ageRow.title, "age", "Object key should be displayed correctly")
    }
    
    func testNodeRowTitleForArrayIndices() throws {
        let data = try XCTUnwrap("[1, 2, 3]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Array indices should be displayed properly
        XCTAssertEqual(root.children.count, 3)
        
        for (index, child) in root.children.enumerated() {
            let nodeRow = NodeRow(node: child)
            XCTAssertEqual(nodeRow.title, "[\(index)]", "Array index should be displayed as [index]")
        }
    }
    
    func testNodeRowTitleForNestedArrays() throws {
        let data = try XCTUnwrap("[[1, 2], [3, 4]]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Nested array indices should be displayed properly
        XCTAssertEqual(root.children.count, 2)
        
        for (index, child) in root.children.enumerated() {
            let nodeRow = NodeRow(node: child)
            XCTAssertEqual(nodeRow.title, "[\(index)]", "Nested array index should be displayed as [index]")
            
            // Check nested children
            for (nestedIndex, nestedChild) in child.children.enumerated() {
                let nestedRow = NodeRow(node: nestedChild)
                XCTAssertEqual(nestedRow.title, "[\(nestedIndex)]", "Nested array child should be displayed as [index]")
            }
        }
    }
    
    func testNodeRowTitleForMixedContent() throws {
        let data = try XCTUnwrap("""
        {
            "name": "John",
            "scores": [95, 87, 92],
            "active": true,
            "metadata": {
                "created": "2023-01-01",
                "tags": ["important", "user"]
            }
        }
        """.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Test different types of keys
        let nameNode = root.children.first { $0.key == "name" }
        let scoresNode = root.children.first { $0.key == "scores" }
        let activeNode = root.children.first { $0.key == "active" }
        let metadataNode = root.children.first { $0.key == "metadata" }
        
        XCTAssertNotNil(nameNode)
        XCTAssertNotNil(scoresNode)
        XCTAssertNotNil(activeNode)
        XCTAssertNotNil(metadataNode)
        
        // Test object keys
        XCTAssertEqual(NodeRow(node: nameNode!).title, "name")
        XCTAssertEqual(NodeRow(node: scoresNode!).title, "scores")
        XCTAssertEqual(NodeRow(node: activeNode!).title, "active")
        XCTAssertEqual(NodeRow(node: metadataNode!).title, "metadata")
        
        // Test array indices within scores
        for (index, child) in scoresNode!.children.enumerated() {
            XCTAssertEqual(NodeRow(node: child).title, "[\(index)]")
        }
        
        // Test nested object keys
        let createdNode = metadataNode!.children.first { $0.key == "created" }
        let tagsNode = metadataNode!.children.first { $0.key == "tags" }
        
        XCTAssertNotNil(createdNode)
        XCTAssertNotNil(tagsNode)
        XCTAssertEqual(NodeRow(node: createdNode!).title, "created")
        XCTAssertEqual(NodeRow(node: tagsNode!).title, "tags")
    }
    
    // MARK: - Tree Structure Tests
    
    func testTreeStructureForSimpleObject() throws {
        let data = try XCTUnwrap("{\"a\": 1, \"b\": 2}".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Root should be an object with 2 children
        XCTAssertEqual(root.value, .object)
        XCTAssertEqual(root.children.count, 2)
        
        // Children should be sorted by key
        let keys = root.children.map { $0.key! }
        XCTAssertEqual(keys, ["a", "b"], "Object keys should be sorted alphabetically")
    }
    
    func testTreeStructureForArray() throws {
        let data = try XCTUnwrap("[1, 2, 3]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Root should be an array with 3 children
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 3)
        
        // Children should have sequential indices
        for (index, child) in root.children.enumerated() {
            XCTAssertEqual(child.key, String(index))
            XCTAssertEqual(child.path, "$[\(index)]")
        }
    }
    
    func testTreeStructureForNestedObjects() throws {
        let data = try XCTUnwrap("""
        {
            "user": {
                "name": "John",
                "age": 30
            },
            "settings": {
                "theme": "dark",
                "notifications": true
            }
        }
        """.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Root should have 2 children
        XCTAssertEqual(root.children.count, 2)
        
        let userNode = root.children.first { $0.key == "user" }
        let settingsNode = root.children.first { $0.key == "settings" }
        
        XCTAssertNotNil(userNode)
        XCTAssertNotNil(settingsNode)
        
        // User node should have 2 children
        XCTAssertEqual(userNode!.value, .object)
        XCTAssertEqual(userNode!.children.count, 2)
        
        // Settings node should have 2 children
        XCTAssertEqual(settingsNode!.value, .object)
        XCTAssertEqual(settingsNode!.children.count, 2)
    }
    
    func testTreeStructureForArrayOfObjects() throws {
        let data = try XCTUnwrap("""
        [
            {"name": "John", "age": 30},
            {"name": "Jane", "age": 25}
        ]
        """.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        // Root should be an array with 2 children
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 2)
        
        // Each child should be an object with 2 children
        for (index, child) in root.children.enumerated() {
            XCTAssertEqual(child.key, String(index))
            XCTAssertEqual(child.value, .object)
            XCTAssertEqual(child.children.count, 2)
            XCTAssertEqual(child.path, "$[\(index)]")
        }
    }
    
    // MARK: - Value Display Tests
    
    func testValueDisplayForPrimitives() throws {
        let data = try XCTUnwrap("""
        {
            "string": "hello",
            "number": 42,
            "boolean": true,
            "nullValue": null
        }
        """.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        let stringNode = root.children.first { $0.key == "string" }
        let numberNode = root.children.first { $0.key == "number" }
        let booleanNode = root.children.first { $0.key == "boolean" }
        let nullNode = root.children.first { $0.key == "nullValue" }
        
        XCTAssertNotNil(stringNode)
        XCTAssertNotNil(numberNode)
        XCTAssertNotNil(booleanNode)
        XCTAssertNotNil(nullNode)
        
        // Test value types
        XCTAssertEqual(stringNode!.value, .string("hello"))
        XCTAssertEqual(numberNode!.value, .number(42))
        XCTAssertEqual(booleanNode!.value, .bool(true))
        XCTAssertEqual(nullNode!.value, .null)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyObject() throws {
        let data = try XCTUnwrap("{}".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        XCTAssertEqual(root.value, .object)
        XCTAssertEqual(root.children.count, 0)
    }
    
    func testEmptyArray() throws {
        let data = try XCTUnwrap("[]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 0)
    }
    
    func testDeeplyNestedStructure() throws {
        let data = try XCTUnwrap("""
        {
            "level1": {
                "level2": {
                    "level3": {
                        "value": "deep"
                    }
                }
            }
        }
        """.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        
        let level1 = root.children.first { $0.key == "level1" }
        let level2 = level1?.children.first { $0.key == "level2" }
        let level3 = level2?.children.first { $0.key == "level3" }
        let value = level3?.children.first { $0.key == "value" }
        
        XCTAssertNotNil(level1)
        XCTAssertNotNil(level2)
        XCTAssertNotNil(level3)
        XCTAssertNotNil(value)
        
        XCTAssertEqual(value!.value, .string("deep"))
    }
}
