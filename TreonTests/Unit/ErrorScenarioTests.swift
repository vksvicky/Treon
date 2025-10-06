import XCTest
import Foundation
@testable import Treon

class ErrorScenarioTests: XCTestCase {
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
    
    // MARK: - Test Malformed JSON
    
    func testOpenFile_malformedJSON_variousCases_flaggedInvalid() async throws {
        let malformedCases = [
            ("Missing closing brace", "{\"test\": \"value\""),
            ("Missing opening brace", "\"test\": \"value\"}"),
            ("Invalid escape", "{\"test\": \"value\\\"}"),
            ("Trailing comma", "{\"test\": \"value\",}"),
            ("Invalid number", "{\"test\": 12.34.56}"),
            ("Invalid boolean", "{\"test\": tru}"),
            ("Invalid null", "{\"test\": nul}"),
            ("Unclosed string", "{\"test\": \"value}"),
            ("Invalid array", "{\"test\": [1, 2, 3,]}"),
            ("Nested error", "{\"test\": {\"nested\": \"value\"}")
        ]
        
        for (description, malformedJSON) in malformedCases {
            let fileURL = tempDirectory.appendingPathComponent("malformed_\(description.replacingOccurrences(of: " ", with: "_")).json")
            try malformedJSON.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let fileInfo = try await fileManager.openFile(url: fileURL)
            XCTAssertFalse(fileInfo.isValidJSON, "Should detect malformed JSON: \(description)")
            XCTAssertNotNil(fileInfo.errorMessage, "Should have error message for: \(description)")
        }
    }
    
    // MARK: - Test File System Errors
    
    func testOpenFile_fileSystemErrors_directoryAndMissing() async throws {
        // Test non-existent file
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.json")
        
        do {
            _ = try await fileManager.openFile(url: nonExistentURL)
            XCTFail("Should throw file not found error")
        } catch FileManagerError.fileNotFound {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Test directory instead of file
        let directoryURL = tempDirectory.appendingPathComponent("directory")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        do {
            _ = try await fileManager.openFile(url: directoryURL)
            XCTFail("Should throw error for directory")
        } catch {
            // Expected some error
        }
    }
    
    // MARK: - Test Permission Errors
    
    func testOpenFile_permissionReadOnly_stillReadable() async throws {
        let content = "{\"test\": \"value\"}"
        let fileURL = tempDirectory.appendingPathComponent("permission_test.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Make file read-only
        try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: fileURL.path)
        
        // Should still be able to read (we're not testing write permissions here)
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        
        // Restore permissions
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: fileURL.path)
    }
    
    // MARK: - Test Network and URL Errors
    
    func testOpenFile_invalidURLs_throwErrors() async throws {
        let invalidURLs = [
            URL(string: "http://invalid-url-that-does-not-exist.com/file.json")!,
            URL(string: "ftp://invalid-ftp.com/file.json")!,
            URL(string: "file:///invalid/path/file.json")!
        ]
        
        for url in invalidURLs {
            do {
                _ = try await fileManager.openFile(url: url)
                XCTFail("Should throw error for invalid URL: \(url)")
            } catch {
                // Expected error
            }
        }
    }
    
    // MARK: - Test Memory and Resource Errors
    
    func testOpenFile_nearLimitResourceConsumption_validUnderLimit() async throws {
        // Create a file that's just under the configured limit with complex structure
        // Use runtime constants to avoid exceeding validation thresholds
        let maxBytes = FileConstants.maxFileSize
        let slackBytes = FileConstants.sizeSlackBytes
        // Stay well under (max + slack) to account for structure/metadata differences
        let safetyMargin: Int64 = 8 * 1024 // 8KB
        let targetBytes = max(0, maxBytes + slackBytes - safetyMargin)
        let content = generateComplexJSON(targetSize: Int(targetBytes))
        let fileURL = tempDirectory.appendingPathComponent("near_limit.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertLessThanOrEqual(fileInfo.size, maxBytes + slackBytes)
    }
    
    // MARK: - Test Concurrent Error Handling
    
    func testOpenFiles_concurrent_validAndInvalid() async throws {
        let validContent = "{\"test\": \"valid\"}"
        let invalidContent = "{\"test\": \"invalid"
        
        // Create valid and invalid files
        let validURL = tempDirectory.appendingPathComponent("valid.json")
        let invalidURL = tempDirectory.appendingPathComponent("invalid.json")
        
        try validContent.write(to: validURL, atomically: true, encoding: .utf8)
        try invalidContent.write(to: invalidURL, atomically: true, encoding: .utf8)
        
        // Process them concurrently
        try await withThrowingTaskGroup(of: FileInfo.self) { group in
            group.addTask {
                try await self.fileManager.openFile(url: validURL)
            }
            group.addTask {
                try await self.fileManager.openFile(url: invalidURL)
            }
            
            var validCount = 0
            var invalidCount = 0
            
            for try await fileInfo in group {
                if fileInfo.isValidJSON {
                    validCount += 1
                } else {
                    invalidCount += 1
                }
            }
            
            XCTAssertEqual(validCount, 1)
            XCTAssertEqual(invalidCount, 1)
        }
    }
    
    // MARK: - Test Edge Cases
    
    func testOpenFile_edgeCases_emptyWhitespaceComments_invalid() async throws {
        // Test empty file
        let emptyURL = tempDirectory.appendingPathComponent("empty.json")
        try "".write(to: emptyURL, atomically: true, encoding: .utf8)
        
        let emptyFileInfo = try await fileManager.openFile(url: emptyURL)
        XCTAssertFalse(emptyFileInfo.isValidJSON)
        
        // Test file with only whitespace
        let whitespaceURL = tempDirectory.appendingPathComponent("whitespace.json")
        try "   \n\t  ".write(to: whitespaceURL, atomically: true, encoding: .utf8)
        
        let whitespaceFileInfo = try await fileManager.openFile(url: whitespaceURL)
        XCTAssertFalse(whitespaceFileInfo.isValidJSON)
        
        // Test file with only comments (not valid JSON)
        let commentURL = tempDirectory.appendingPathComponent("comment.json")
        try "// This is a comment\n{\"test\": \"value\"}".write(to: commentURL, atomically: true, encoding: .utf8)
        
        let commentFileInfo = try await fileManager.openFile(url: commentURL)
        XCTAssertFalse(commentFileInfo.isValidJSON)
    }
    
    // MARK: - Test Unicode and Encoding Errors
    
    func testOpenFile_unicodeAndInvalidEncoding() async throws {
        // Test valid Unicode
        let unicodeContent = "{\"emoji\": \"🚀\", \"unicode\": \"测试\", \"special\": \"café\"}"
        let unicodeURL = tempDirectory.appendingPathComponent("unicode.json")
        try unicodeContent.write(to: unicodeURL, atomically: true, encoding: .utf8)
        
        let unicodeFileInfo = try await fileManager.openFile(url: unicodeURL)
        XCTAssertTrue(unicodeFileInfo.isValidJSON)
        
        // Test invalid UTF-8 (this is tricky to create in Swift)
        let invalidUTF8URL = tempDirectory.appendingPathComponent("invalid_utf8.json")
        let invalidData = Data([0xFF, 0xFE, 0xFD]) // Invalid UTF-8
        try invalidData.write(to: invalidUTF8URL)
        
        do {
            _ = try await fileManager.openFile(url: invalidUTF8URL)
            // If it doesn't throw, it should at least be invalid JSON
        } catch {
            // Expected error for invalid encoding
        }
    }
    
    // MARK: - Test File Corruption
    
    func testOpenFile_corruptedFile_detectsInvalid() async throws {
        let originalContent = "{\"test\": \"value\", \"number\": 42}"
        let corruptedURL = tempDirectory.appendingPathComponent("corrupted.json")
        try originalContent.write(to: corruptedURL, atomically: true, encoding: .utf8)
        
        // Corrupt the file by overwriting part of it
        let corruptedData = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        let fileHandle = try FileHandle(forWritingTo: corruptedURL)
        fileHandle.seek(toFileOffset: 5) // Seek to middle of file
        fileHandle.write(corruptedData)
        fileHandle.closeFile()
        
        let corruptedFileInfo = try await fileManager.openFile(url: corruptedURL)
        XCTAssertFalse(corruptedFileInfo.isValidJSON)
        XCTAssertNotNil(corruptedFileInfo.errorMessage)
    }
    
    // MARK: - Helper Methods
    
    private func generateComplexJSON(targetSize: Int) -> String {
        var content = "{\n"
        var currentSize = 2
        
        while currentSize < targetSize {
            let key = "key_\(currentSize)"
            let remaining = targetSize - currentSize - 100
            let repeatCount = max(0, min(1000, remaining))
            let value = String(repeating: "x", count: repeatCount)
            
            content += "  \"\(key)\": \"\(value)\""
            currentSize += key.count + value.count + 8
            
            if currentSize < targetSize - 10 {
                content += ","
                currentSize += 1
            }
            content += "\n"
            currentSize += 1
        }
        
        content += "}"
        return content
    }
}
