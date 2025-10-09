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

    // MARK: - JSON Array Tests

    func testPrettyPrintArray() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[1,2,3]".data(using: .utf8))
        let output = try formatter.prettyPrinted(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertNotNil(text)
        XCTAssertTrue(text!.contains("\n"))
        XCTAssertTrue(text!.contains("1"))
        XCTAssertTrue(text!.contains("2"))
        XCTAssertTrue(text!.contains("3"))
    }

    func testMinifyArray() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[\n  1,\n  2,\n  3\n]".data(using: .utf8))
        let output = try formatter.minified(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertEqual(text, "[1,2,3]")
    }

    func testPrettyPrintArrayOfObjects() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[{\"name\":\"John\"},{\"name\":\"Jane\"}]".data(using: .utf8))
        let output = try formatter.prettyPrinted(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertNotNil(text)
        XCTAssertTrue(text!.contains("\n"))
        XCTAssertTrue(text!.contains("John"))
        XCTAssertTrue(text!.contains("Jane"))
    }

    func testMinifyArrayOfObjects() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[\n  {\n    \"name\": \"John\"\n  },\n  {\n    \"name\": \"Jane\"\n  }\n]".data(using: .utf8))
        let output = try formatter.minified(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertEqual(text, "[{\"name\":\"John\"},{\"name\":\"Jane\"}]")
    }

    func testPrettyPrintEmptyArray() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[]".data(using: .utf8))
        let output = try formatter.prettyPrinted(from: input)
        let text = String(data: output, encoding: .utf8)
        // JSONSerialization might add formatting, so we just check it's valid JSON
        XCTAssertNotNil(text)
        // The output should be valid JSON that represents an empty array
        // It could be "[]" or "[\n]" depending on JSONSerialization behavior
        XCTAssertTrue(text!.contains("[") && text!.contains("]"))
        // Verify it's still valid JSON by parsing it back
        let parsedData = try XCTUnwrap(text!.data(using: .utf8))
        let parsedArray = try JSONSerialization.jsonObject(with: parsedData) as? [Any]
        XCTAssertNotNil(parsedArray)
        XCTAssertEqual(parsedArray?.count, 0)
    }

    func testMinifyEmptyArray() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[]".data(using: .utf8))
        let output = try formatter.minified(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertEqual(text, "[]")
    }

    func testPrettyPrintNestedArrays() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[[1,2],[3,4]]".data(using: .utf8))
        let output = try formatter.prettyPrinted(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertNotNil(text)
        XCTAssertTrue(text!.contains("\n"))
        XCTAssertTrue(text!.contains("1"))
        XCTAssertTrue(text!.contains("2"))
        XCTAssertTrue(text!.contains("3"))
        XCTAssertTrue(text!.contains("4"))
    }

    func testMinifyNestedArrays() throws {
        let formatter = JSONFormatter()
        let input = try XCTUnwrap("[\n  [\n    1,\n    2\n  ],\n  [\n    3,\n    4\n  ]\n]".data(using: .utf8))
        let output = try formatter.minified(from: input)
        let text = String(data: output, encoding: .utf8)
        XCTAssertEqual(text, "[[1,2],[3,4]]")
    }

    // MARK: - Static Convenience Method Tests

    func testStaticPrettyPrint() throws {
        let input = "[1,2,3]"
        let output = try JSONFormatter.prettyPrint(input)
        XCTAssertTrue(output.contains("\n"))
        XCTAssertTrue(output.contains("1"))
        XCTAssertTrue(output.contains("2"))
        XCTAssertTrue(output.contains("3"))
    }

    func testStaticMinify() throws {
        let input = "[\n  1,\n  2,\n  3\n]"
        let output = try JSONFormatter.minify(input)
        XCTAssertEqual(output, "[1,2,3]")
    }

    func testStaticPrettyPrintArrayOfObjects() throws {
        let input = "[{\"name\":\"John\",\"age\":30},{\"name\":\"Jane\",\"age\":25}]"
        let output = try JSONFormatter.prettyPrint(input)
        XCTAssertTrue(output.contains("\n"))
        XCTAssertTrue(output.contains("John"))
        XCTAssertTrue(output.contains("Jane"))
        XCTAssertTrue(output.contains("30"))
        XCTAssertTrue(output.contains("25"))
    }

    func testStaticMinifyArrayOfObjects() throws {
        let input = "[\n  {\n    \"name\": \"John\",\n    \"age\": 30\n  },\n  {\n    \"name\": \"Jane\",\n    \"age\": 25\n  }\n]"
        let output = try JSONFormatter.minify(input)
        XCTAssertEqual(output, "[{\"name\":\"John\",\"age\":30},{\"name\":\"Jane\",\"age\":25}]")
    }

    // MARK: - Edge Cases

    func testPrettyPrintArrayWithMixedTypes() throws {
        let input = "[\"string\",42,true,null,{\"key\":\"value\"},[1,2,3]]"
        let output = try JSONFormatter.prettyPrint(input)
        XCTAssertTrue(output.contains("\n"))
        XCTAssertTrue(output.contains("string"))
        XCTAssertTrue(output.contains("42"))
        XCTAssertTrue(output.contains("true"))
        XCTAssertTrue(output.contains("null"))
        XCTAssertTrue(output.contains("key"))
        XCTAssertTrue(output.contains("value"))
    }

    func testMinifyArrayWithMixedTypes() throws {
        let input = "[\n  \"string\",\n  42,\n  true,\n  null,\n  {\n    \"key\": \"value\"\n  },\n  [\n    1,\n    2,\n    3\n  ]\n]"
        let output = try JSONFormatter.minify(input)
        XCTAssertEqual(output, "[\"string\",42,true,null,{\"key\":\"value\"},[1,2,3]]")
    }
}


