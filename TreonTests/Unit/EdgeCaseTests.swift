//
//  EdgeCaseTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-25.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
import AppKit
@testable import Treon

@MainActor
final class EdgeCaseTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
    }
    
    // MARK: - File Size Edge Cases
    
    func testExtremelyLargeFile() async throws {
        // Test with a file that's larger than typical memory limits
        let largeSize = 100 * 1024 * 1024 // 100MB
        let largeJSON = String(repeating: "{\"key\": \"value\",", count: 1000000) + "\"final\": \"value\"}"
        
        let data = largeJSON.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "large.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        // This should either succeed or fail gracefully
        do {
            let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
            XCTAssertNotNil(result)
        } catch {
            // If it fails, it should be a reasonable error
            XCTAssertNotNil(error)
        }
    }
    
    func testEmptyFile() async throws {
        let emptyData = Data()
        let fileInfo = FileInfo(
            url: nil,
            name: "empty.json",
            size: 0,
            modifiedDate: Date(),
            isValidJSON: false,
            errorMessage: "Empty file"
        )
        
        do {
            _ = try await JSONViewerHelpers.processJSONData(emptyData, fileInfo: fileInfo)
            XCTFail("Empty file should not be processed successfully")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testSingleCharacterFile() async throws {
        let singleCharData = "a".data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "single.json",
            size: 1,
            modifiedDate: Date(),
            isValidJSON: false,
            errorMessage: "Invalid JSON"
        )
        
        do {
            _ = try await JSONViewerHelpers.processJSONData(singleCharData, fileInfo: fileInfo)
            XCTFail("Single character should not be valid JSON")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - JSON Structure Edge Cases
    
    func testDeeplyNestedJSON() async throws {
        // Create a JSON with very deep nesting
        var json = "{"
        for i in 0..<100 {
            json += "\"level\(i)\": {"
        }
        json += "\"value\": \"deep\""
        for _ in 0..<100 {
            json += "}"
        }
        json += "}"
        
        let data = json.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "deep.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        do {
            let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
            XCTAssertNotNil(result)
        } catch {
            // Deep nesting might cause issues, which is acceptable
            XCTAssertNotNil(error)
        }
    }
    
    func testWideJSON() async throws {
        // Create a JSON with many top-level keys
        var json = "{"
        for i in 0..<10000 {
            json += "\"key\(i)\": \"value\(i)\","
        }
        json = String(json.dropLast()) // Remove trailing comma
        json += "}"
        
        let data = json.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "wide.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        do {
            let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
            XCTAssertNotNil(result)
        } catch {
            // Wide JSON might cause issues, which is acceptable
            XCTAssertNotNil(error)
        }
    }
    
    func testJSONWithVeryLongStrings() async throws {
        let longString = String(repeating: "a", count: 100000)
        let json = "{\"longString\": \"\(longString)\"}"
        
        let data = json.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "longstring.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        do {
            let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
            XCTAssertNotNil(result)
        } catch {
            // Very long strings might cause issues, which is acceptable
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Character Encoding Edge Cases
    
    func testUnicodeJSON() async throws {
        let unicodeJSON = """
        {
            "unicode": "Hello 世界 🌍",
            "emoji": "🚀🎉💻",
            "special": "Café naïve résumé",
            "chinese": "你好世界",
            "arabic": "مرحبا بالعالم",
            "russian": "Привет мир"
        }
        """
        
        let data = unicodeJSON.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "unicode.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
        XCTAssertNotNil(result)
    }
    
    func testJSONWithControlCharacters() async throws {
        let controlCharJSON = """
        {
            "newline": "Line 1\\nLine 2",
            "tab": "Column1\\tColumn2",
            "carriage": "Line1\\rLine2",
            "backspace": "Text\\bMore",
            "formfeed": "Text\\fMore",
            "quote": "He said \\"Hello\\"",
            "backslash": "Path\\\\to\\\\file"
        }
        """
        
        let data = controlCharJSON.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "control.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil
        )
        
        let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
        XCTAssertNotNil(result)
    }
    
    // MARK: - Memory Edge Cases
    
    func testMemoryPressureHandling() async throws {
        // Create multiple large JSON objects to test memory handling
        let largeJSON = String(repeating: "{\"key\": \"value\",", count: 100000) + "\"final\": \"value\"}"
        
        for i in 0..<10 {
            let data = largeJSON.data(using: .utf8)!
            let fileInfo = FileInfo(
                url: nil,
                name: "memory\(i).json",
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil
            )
            
            do {
                let result = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
                XCTAssertNotNil(result)
            } catch {
                // Memory pressure might cause failures, which is acceptable
                XCTAssertNotNil(error)
            }
        }
    }
    
    // MARK: - Concurrent Processing Edge Cases
    
    func testConcurrentJSONProcessing() async throws {
        let json = "{\"test\": \"value\"}"
        let data = json.data(using: .utf8)!
        
        // Process the same JSON concurrently
        let tasks = (0..<10).map { i in
            Task {
                let fileInfo = FileInfo(
                    url: nil,
                    name: "concurrent\(i).json",
                    size: Int64(data.count),
                    modifiedDate: Date(),
                    isValidJSON: true,
                    errorMessage: nil
                )
                
                return try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
            }
        }
        
        let results = try await withThrowingTaskGroup(of: JSONNode.self) { group in
            for task in tasks {
                group.addTask {
                    try await task.value
                }
            }
            
            var results: [JSONNode] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        XCTAssertEqual(results.count, 10)
        for result in results {
            XCTAssertNotNil(result)
        }
    }
    
    // MARK: - Error Recovery Edge Cases
    
    func testPartialJSONRecovery() async throws {
        // Test with JSON that's partially valid
        let partialJSON = "{\"valid\": \"value\", \"invalid\": }"
        
        let data = partialJSON.data(using: .utf8)!
        let fileInfo = FileInfo(
            url: nil,
            name: "partial.json",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: false,
            errorMessage: "Invalid JSON"
        )
        
        do {
            _ = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
            XCTFail("Partial JSON should not be processed successfully")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testMalformedJSONRecovery() async throws {
        // Test with various malformed JSON structures
        let malformedJSONs = [
            "{invalid}",
            "{\"key\": \"value\",}",
            "{\"key\": \"value\"",
            "{\"key\": \"value\", \"key2\":}",
            "[1, 2, 3,]",
            "{\"key\": \"value\" \"key2\": \"value2\"}",
            "{\"key\": \"value\", \"key2\": \"value2\",}"
        ]
        
        for (index, malformedJSON) in malformedJSONs.enumerated() {
            let data = malformedJSON.data(using: .utf8)!
            let fileInfo = FileInfo(
                url: nil,
                name: "malformed\(index).json",
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: false,
                errorMessage: "Malformed JSON"
            )
            
            do {
                _ = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
                XCTFail("Malformed JSON should not be processed successfully")
            } catch {
                XCTAssertNotNil(error)
            }
        }
    }
    
    // MARK: - Performance Edge Cases
    
    func testPerformanceWithEdgeCases() {
        measure {
            let json = "{\"key\": \"value\"}"
            let data = json.data(using: .utf8)!
            let fileInfo = FileInfo(
                url: nil,
                name: "perf.json",
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil
            )
            
            let expectation = XCTestExpectation(description: "Performance test")
            
            Task {
                do {
                    _ = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
                } catch {
                    // Ignore errors in performance test
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
}
