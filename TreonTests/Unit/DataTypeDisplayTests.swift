import XCTest
@testable import Treon

final class DataTypeDisplayTests: XCTestCase {

    func testStringDataType() throws {
        let jsonString = "{\"name\": \"John\"}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let nameNode = root.children.first { $0.key == "name" }

        XCTAssertNotNil(nameNode)
        XCTAssertEqual(nameNode?.dataType, "String")
    }

    func testNumberDataType() throws {
        let jsonString = "{\"age\": 25}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let ageNode = root.children.first { $0.key == "age" }

        XCTAssertNotNil(ageNode)
        XCTAssertEqual(ageNode?.dataType, "Number")
    }

    func testBooleanDataType() throws {
        let jsonString = "{\"isActive\": true}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let isActiveNode = root.children.first { $0.key == "isActive" }

        XCTAssertNotNil(isActiveNode)
        // Let's see what the actual data type is
        let actualDataType = isActiveNode?.dataType ?? "nil"
        XCTAssertEqual(actualDataType, "Boolean", "Expected 'Boolean' but got '\(actualDataType)'")
    }

    func testObjectDataType() throws {
        let jsonString = "{\"user\": {\"name\": \"John\"}}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let userNode = root.children.first { $0.key == "user" }

        XCTAssertNotNil(userNode)
        XCTAssertEqual(userNode?.dataType, "Object")
    }

    func testArrayDataType() throws {
        let jsonString = "{\"items\": [1, 2, 3]}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let itemsNode = root.children.first { $0.key == "items" }

        XCTAssertNotNil(itemsNode)
        XCTAssertEqual(itemsNode?.dataType, "Array")
    }

    func testNullDataType() throws {
        let jsonString = "{\"value\": null}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let valueNode = root.children.first { $0.key == "value" }

        XCTAssertNotNil(valueNode)
        XCTAssertEqual(valueNode?.dataType, "null")
    }

    func testRootObjectDataType() throws {
        let jsonString = "{\"name\": \"John\"}"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)

        XCTAssertEqual(root.dataType, "Object")
    }

    func testRootArrayDataType() throws {
        let jsonString = "[1, 2, 3]"
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)

        XCTAssertEqual(root.dataType, "Array")
    }

    func testComplexNestedDataTypes() throws {
        let jsonString = """
        {
            "user": {
                "name": "John",
                "age": 25,
                "isActive": true,
                "tags": ["admin", "user"],
                "profile": null
            }
        }
        """
        let data = try XCTUnwrap(jsonString.data(using: .utf8))
        let root = try JSONTreeBuilder.build(from: data)
        let userNode = root.children.first { $0.key == "user" }

        XCTAssertNotNil(userNode)
        XCTAssertEqual(userNode?.dataType, "Object")

        let nameNode = userNode?.children.first { $0.key == "name" }
        let ageNode = userNode?.children.first { $0.key == "age" }
        let isActiveNode = userNode?.children.first { $0.key == "isActive" }
        let tagsNode = userNode?.children.first { $0.key == "tags" }
        let profileNode = userNode?.children.first { $0.key == "profile" }

        XCTAssertEqual(nameNode?.dataType, "String")
        XCTAssertEqual(ageNode?.dataType, "Number")
        XCTAssertEqual(isActiveNode?.dataType, "Boolean")
        XCTAssertEqual(tagsNode?.dataType, "Array")
        XCTAssertEqual(profileNode?.dataType, "null")
    }
}
