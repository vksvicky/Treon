import XCTest
import Foundation
@testable import Treon

final class JSONFormatterTests: XCTestCase {
    func testPrettyPrintedProducesIndentedJSON() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("{\"a\":1}".data(using: .utf8))
        let output = try formatter.prettyPrinted(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertNotNil(text)
        XCTAssertTrue(text!.contains("\n"))
    }

    func testMinifiedProducesCompactJSON() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("{\n  \"a\": 1\n}".data(using: .utf8))
        let output = try formatter.minified(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertEqual(text, "{\"a\":1}")
    }
}


