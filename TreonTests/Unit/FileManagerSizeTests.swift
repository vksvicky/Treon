import XCTest
import Foundation
@testable import Treon

@MainActor
class FileManagerSizeTests: XCTestCase {
    var fileManager: TreonFileManager!
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        fileManager = TreonFileManager.shared
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        fileManager.clearAllRecentFiles()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        fileManager.clearAllRecentFiles()
        super.tearDown()
    }

    func testOpenFile_smallJSON_under1KB() async throws {
        let smallJSON = "{\"test\": \"small\"}"
        let fileURL = tempDirectory.appendingPathComponent("small.json")
        try smallJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertLessThan(fileInfo.size, 1024)
    }

    func testOpenFile_largeJSON_atLeast1MB() async throws {
        var largeJSON = "{\n"
        var current = 2
        let target = 1 * 1024 * 1024
        var index = 0
        while current < target {
            let key = "key_\(index)"
            let value = String(repeating: "v", count: min(1024, max(0, target - current - 100)))
            largeJSON += "  \"\(key)\": \"\(value)\""
            current += key.count + value.count + 8
            if current < target - 10 { largeJSON += ","; current += 1 }
            largeJSON += "\n"; current += 1
            index += 1
        }
        largeJSON += "}"
        let fileURL = tempDirectory.appendingPathComponent("large.json")
        try largeJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThanOrEqual(fileInfo.size, 1024 * 1024)
    }

    func testOpenFile_veryLargeJSON_atLeast10MB() async throws {
        var json = "{\n"
        var current = 2
        let target = 10 * 1024 * 1024
        var index = 0
        while current < target {
            let key = "key_\(index)"
            let value = String(repeating: "v", count: min(2048, max(0, target - current - 100)))
            json += "  \"\(key)\": \"\(value)\""
            current += key.count + value.count + 8
            if current < target - 10 { json += ","; current += 1 }
            json += "\n"; current += 1
            index += 1
        }
        json += "}"
        let fileURL = tempDirectory.appendingPathComponent("verylarge.json")
        try json.write(to: fileURL, atomically: true, encoding: .utf8)
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThanOrEqual(fileInfo.size, 10 * 1024 * 1024)
    }

    func testOpenFile_extremelyLargeJSON_underMaxLimit() async throws {
        let maxBytes = TreonFileManager.shared.maxFileSize
        let slackBytes = TreonFileManager.shared.sizeSlackBytes
        let safetyMargin: Int64 = 16 * 1024
        let target = Int(max(0, maxBytes + slackBytes - safetyMargin))

        var json = "{\n"
        var current = 2
        var index = 0
        var isFirstEntry = true
        while current < target {
            let key = "key_\(index)"
            let remaining = max(0, target - current - 100)
            let value = String(repeating: "v", count: min(4096, remaining))
            if !isFirstEntry { json += ",\n"; current += 2 }
            json += "  \"\(key)\": \"\(value)\""
            current += key.count + value.count + 8
            isFirstEntry = false
            index += 1
        }
        json += "\n}"
        let fileURL = tempDirectory.appendingPathComponent("extremelylarge.json")
        try json.write(to: fileURL, atomically: true, encoding: .utf8)
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertLessThanOrEqual(fileInfo.size, maxBytes + slackBytes)
    }

    func testOpenFile_accepts500MB_within1GBLimit() async throws {
        // Create a 500MB file (within 1GB limit)
        let largeContent = String(repeating: "a", count: 500 * 1024 * 1024) // 500MB
        let fileURL = tempDirectory.appendingPathComponent("500mb.json")
        try largeContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // This should succeed with the new 1GB limit
        let result = try await fileManager.openFile(url: fileURL)
        XCTAssertNotNil(result)
    }
    
    func testOpenFile_rejectsOver1GBLimit() async throws {
        // Create a file larger than the 1GB limit
        let largeContent = String(repeating: "a", count: 1025 * 1024 * 1024) // 1025MB
        let fileURL = tempDirectory.appendingPathComponent("toolarge.json")
        try largeContent.write(to: fileURL, atomically: true, encoding: .utf8)
        do {
            _ = try await fileManager.openFile(url: fileURL)
            XCTFail("Should have thrown file too large error")
        } catch FileManagerError.fileTooLarge {
            // expected
        }
    }
}


