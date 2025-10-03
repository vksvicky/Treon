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
}


