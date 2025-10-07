import XCTest
import Foundation
@testable import Treon

final class SmokeTests: XCTestCase {
    var fileManager: TreonFileManager!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        fileManager = TreonFileManager.shared
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        fileManager.clearRecentFiles()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        fileManager.clearRecentFiles()
        super.tearDown()
    }
    
    func testOpenFile_validSmallJSON_returnsValid() async throws {
        let content = "{\"hello\": \"world\"}"
        let url = tempDirectory.appendingPathComponent("valid.json")
        try content.write(to: url, atomically: true, encoding: .utf8)
        
        let info = try await fileManager.openFile(url: url)
        XCTAssertEqual(info.name, "valid.json")
        XCTAssertTrue(info.isValidJSON)
        XCTAssertGreaterThan(info.size, 0)
    }
    
    func testOpenFile_invalidJSON_setsErrorMessage() async throws {
        let content = "{\"hello\": \"world\"" // missing closing brace
        let url = tempDirectory.appendingPathComponent("invalid.json")
        try content.write(to: url, atomically: true, encoding: .utf8)
        
        let info = try await fileManager.openFile(url: url)
        XCTAssertFalse(info.isValidJSON)
        XCTAssertNotNil(info.errorMessage)
    }
    
    func testOpenFile_rejectsTooLargeFile() async throws {
        // Create a file that exceeds configured limit by at least 1 byte
        let maxBytes = await TreonFileManager.shared.maxFileSize
        let slackBytes = await TreonFileManager.shared.sizeSlackBytes
        let overLimitBytes = Int(maxBytes + slackBytes + 1)
        let largeContent = String(repeating: "a", count: overLimitBytes)
        let url = tempDirectory.appendingPathComponent("toolarge.json")
        try largeContent.write(to: url, atomically: true, encoding: .utf8)
        
        do {
            _ = try await fileManager.openFile(url: url)
            XCTFail("Expected fileTooLarge error for file exceeding limit")
        } catch FileManagerError.fileTooLarge(let actual, let max) {
            XCTAssertGreaterThan(actual, max)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

 