import XCTest
@testable import Treon

final class JSONNodeTests: XCTestCase {
    func testBuildTreeFromSimpleObject() throws {
        let data = try XCTUnwrap("{\"a\":1,\"b\":[true,null]}".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.children.count, 2)
    }

    func testArrayChildrenPaths() throws {
        let data = try XCTUnwrap("[1,2]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.children.first?.path, "$[0]")
        XCTAssertEqual(root.children.last?.path, "$[1]")
    }
    
    // MARK: - JSON Array Tests
    
    func testBuildTreeFromSimpleArray() throws {
        let data = try XCTUnwrap("[1, 2, 3]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 3)
        XCTAssertEqual(root.children[0].key, "0")
        XCTAssertEqual(root.children[1].key, "1")
        XCTAssertEqual(root.children[2].key, "2")
    }
    
    func testBuildTreeFromArrayOfObjects() throws {
        let jsonString = """
        [
            {"name": "John", "age": 30},
            {"name": "Jane", "age": 25}
        ]
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 2)
        
        // Check first object
        let firstObject = root.children[0]
        XCTAssertEqual(firstObject.path, "$[0]")
        XCTAssertEqual(firstObject.value, .object)
        XCTAssertEqual(firstObject.children.count, 2)
        
        // Check second object
        let secondObject = root.children[1]
        XCTAssertEqual(secondObject.path, "$[1]")
        XCTAssertEqual(secondObject.value, .object)
        XCTAssertEqual(secondObject.children.count, 2)
    }
    
    func testBuildTreeFromNestedArrays() throws {
        let jsonString = """
        [
            [1, 2, 3],
            ["a", "b", "c"],
            [true, false, null]
        ]
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 3)
        
        // Check nested arrays
        for i in 0..<3 {
            let nestedArray = root.children[i]
            XCTAssertEqual(nestedArray.path, "$[\(i)]")
            XCTAssertEqual(nestedArray.value, .array)
            XCTAssertEqual(nestedArray.children.count, 3)
        }
    }
    
    func testBuildTreeFromComplexArray() throws {
        let jsonString = """
        [
            {
                "_id": "68e4117f5c89dd802ede80ee",
                "index": 0,
                "isActive": true,
                "balance": "$1,639.30",
                "tags": ["sunt", "dolore", "tempor"]
            },
            {
                "_id": "68e4117f8bce8ebe82f3f7df",
                "index": 1,
                "isActive": false,
                "balance": "$1,949.59",
                "tags": ["adipisicing", "pariatur", "eiusmod"]
            }
        ]
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 2)
        
        // Check first object structure
        let firstObject = root.children[0]
        XCTAssertEqual(firstObject.path, "$[0]")
        XCTAssertEqual(firstObject.value, .object)
        XCTAssertEqual(firstObject.children.count, 5)
        
        // Check tags array in first object
        let tagsArray = firstObject.children.first { $0.key == "tags" }
        XCTAssertNotNil(tagsArray)
        XCTAssertEqual(tagsArray?.value, .array)
        XCTAssertEqual(tagsArray?.children.count, 3)
    }
    
    // MARK: - Various JSON Format Tests
    
    func testBuildTreeFromEmptyArray() throws {
        let data = try XCTUnwrap("[]".data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 0)
    }
    
    func testBuildTreeFromArrayWithMixedTypes() throws {
        let jsonString = """
        [
            "string",
            42,
            3.14,
            true,
            false,
            null,
            {"nested": "object"},
            [1, 2, 3]
        ]
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 8)
        
        // Check different value types
        XCTAssertEqual(root.children[0].value, .string("string"))
        XCTAssertEqual(root.children[1].value, .number(42))
        XCTAssertEqual(root.children[2].value, .number(3.14))
        XCTAssertEqual(root.children[3].value, .bool(true))
        XCTAssertEqual(root.children[4].value, .bool(false))
        XCTAssertEqual(root.children[5].value, .null)
        XCTAssertEqual(root.children[6].value, .object)
        XCTAssertEqual(root.children[7].value, .array)
    }
    
    func testBuildTreeFromArrayWithNumbers() throws {
        let jsonString = """
        [
            0,
            -1,
            1.5,
            -3.14,
            1e10,
            -2.5e-3
        ]
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 6)
        
        // Check number values
        XCTAssertEqual(root.children[0].value, .number(0))
        XCTAssertEqual(root.children[1].value, .number(-1))
        XCTAssertEqual(root.children[2].value, .number(1.5))
        XCTAssertEqual(root.children[3].value, .number(-3.14))
        XCTAssertEqual(root.children[4].value, .number(1e10))
        XCTAssertEqual(root.children[5].value, .number(-2.5e-3))
    }
    
    func testBuildTreeFromArrayWithStrings() throws {
        let jsonString = """
        [
            "simple",
            "with spaces",
            "with\\"quotes\\"",
            "with\\\\backslashes",
            "with\\nnewlines",
            "with\\ttabs",
            "unicode: 🚀",
            ""
        ]
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        XCTAssertEqual(root.path, "$")
        XCTAssertEqual(root.value, .array)
        XCTAssertEqual(root.children.count, 8)
        
        // Check string values
        XCTAssertEqual(root.children[0].value, .string("simple"))
        XCTAssertEqual(root.children[1].value, .string("with spaces"))
        XCTAssertEqual(root.children[2].value, .string("with\"quotes\""))
        XCTAssertEqual(root.children[3].value, .string("with\\backslashes"))
        XCTAssertEqual(root.children[4].value, .string("with\nnewlines"))
        XCTAssertEqual(root.children[5].value, .string("with\ttabs"))
        XCTAssertEqual(root.children[6].value, .string("unicode: 🚀"))
        XCTAssertEqual(root.children[7].value, .string(""))
    }
}


