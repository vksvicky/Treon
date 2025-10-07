import XCTest
@testable import Treon

@MainActor
final class TreeExpansionStateTests: XCTestCase {
    func makeRoot() throws -> JSONNode {
        let json = """
        {"a":1,"b":{"c":2,"d":[3,4]},"e":[{"f":5},6]}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        return try JSONTreeBuilder.build(from: data)
    }

    func testExpandAllAndCollapseAll() throws {
        let root = try makeRoot()
        let state = TreeExpansionState()
        XCTAssertTrue(state.expandedIds.isEmpty)

        state.expandAll(root: root)
        // Should include root and all descendants
        XCTAssertTrue(state.isExpanded(root))
        for child in root.children {
            XCTAssertTrue(state.isExpanded(child))
            for grand in child.children {
                XCTAssertTrue(state.isExpanded(grand))
            }
        }

        state.resetAll()
        XCTAssertTrue(state.expandedIds.isEmpty)
    }

    func testExpandCollapseCurrentNode() throws {
        let root = try makeRoot()
        let state = TreeExpansionState()
        let b = try XCTUnwrap(root.children.first { $0.key == "b" })
        let d = try XCTUnwrap(b.children.first { $0.key == "d" })

        state.expand(node: b, includeDescendants: false)
        XCTAssertTrue(state.isExpanded(b))
        XCTAssertFalse(state.isExpanded(d))

        state.expand(node: b, includeDescendants: true)
        XCTAssertTrue(state.isExpanded(d))

        state.collapse(node: b, includeDescendants: false)
        XCTAssertFalse(state.isExpanded(b))
        // d remains expanded since we didn't collapse descendants
        XCTAssertTrue(state.isExpanded(d))

        state.collapse(node: b, includeDescendants: true)
        XCTAssertFalse(state.isExpanded(d))
    }
}
