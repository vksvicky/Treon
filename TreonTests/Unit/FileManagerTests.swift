import XCTest
import Foundation
@testable import Treon

class FileManagerTests: XCTestCase {
    var fileManager: TreonFileManager!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        fileManager = TreonFileManager.shared
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        // Create temp directory
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // Clear recent files for clean test state
        fileManager.clearRecentFiles()
    }
    
    override func tearDown() {
        // Clean up temp directory
        try? FileManager.default.removeItem(at: tempDirectory)
        fileManager.clearRecentFiles()
        super.tearDown()
    }
    
    // MARK: - Test File Creation
    
    func testCreateNewFile() {
        let fileInfo = fileManager.createNewFile()
        
        XCTAssertEqual(fileInfo.name, "Untitled.json")
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertGreaterThan(fileInfo.size, 0)
    }
    
    // MARK: - Test JSON Validation
    
    func testValidJSONFile() async throws {
        let validJSON = """
        {
            "name": "Test",
            "value": 42,
            "array": [1, 2, 3],
            "object": {
                "nested": true
            }
        }
        """
        
        let fileURL = tempDirectory.appendingPathComponent("valid.json")
        try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertEqual(fileInfo.name, "valid.json")
    }
    
    func testInvalidJSONFile() async throws {
        let invalidJSON = """
        {
            "name": "Test",
            "value": 42,
            "array": [1, 2, 3,
            "object": {
                "nested": true
            }
        }
        """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid.json")
        try invalidJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertFalse(fileInfo.isValidJSON)
        XCTAssertNotNil(fileInfo.errorMessage)
        XCTAssertEqual(fileInfo.name, "invalid.json")
    }
    
    func testEmptyJSONFile() async throws {
        let emptyJSON = ""
        
        let fileURL = tempDirectory.appendingPathComponent("empty.json")
        try emptyJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertFalse(fileInfo.isValidJSON)
        XCTAssertNotNil(fileInfo.errorMessage)
    }
    
    func testNonJSONFile() async throws {
        let nonJSON = "This is not JSON content"
        
        let fileURL = tempDirectory.appendingPathComponent("notjson.json")
        try nonJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertFalse(fileInfo.isValidJSON)
        XCTAssertNotNil(fileInfo.errorMessage)
    }
    
    // MARK: - Test File Size Validation
    
    func testSmallFile() async throws {
        let smallJSON = "{\"test\": \"small\"}"
        
        let fileURL = tempDirectory.appendingPathComponent("small.json")
        try smallJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertLessThan(fileInfo.size, 1024) // Less than 1KB
    }
    
    func testLargeFile() async throws {
        // Create a large JSON file (about 1MB)
        var largeJSON = "{\n"
        for i in 0..<10000 {
            largeJSON += "  \"key\(i)\": \"value\(i)\",\n"
        }
        largeJSON += "  \"end\": true\n}"
        
        let fileURL = tempDirectory.appendingPathComponent("large.json")
        try largeJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThan(fileInfo.size, 1024 * 1024) // Greater than 1MB
    }
    
    func testVeryLargeFile() async throws {
        // Create a very large JSON file (about 10MB)
        var veryLargeJSON = "{\n"
        for i in 0..<100000 {
            veryLargeJSON += "  \"key\(i)\": \"value\(i)\",\n"
        }
        veryLargeJSON += "  \"end\": true\n}"
        
        let fileURL = tempDirectory.appendingPathComponent("verylarge.json")
        try veryLargeJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThan(fileInfo.size, 10 * 1024 * 1024) // Greater than 10MB
    }
    
    func testExtremelyLargeFile() async throws {
        // Create an extremely large JSON file (about 50MB)
        var extremelyLargeJSON = "{\n"
        for i in 0..<500000 {
            extremelyLargeJSON += "  \"key\(i)\": \"value\(i)\",\n"
        }
        extremelyLargeJSON += "  \"end\": true\n}"
        
        let fileURL = tempDirectory.appendingPathComponent("extremelylarge.json")
        try extremelyLargeJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThan(fileInfo.size, 50 * 1024 * 1024) // Greater than 50MB
    }
    
    // MARK: - Test File Size Limits
    
    func testFileSizeLimit() async throws {
        // Create a file larger than 100MB limit
        let largeContent = String(repeating: "a", count: 101 * 1024 * 1024) // 101MB
        
        let fileURL = tempDirectory.appendingPathComponent("toolarge.json")
        try largeContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        do {
            _ = try await fileManager.openFile(url: fileURL)
            XCTFail("Should have thrown file too large error")
        } catch FileManagerError.fileTooLarge {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test File Not Found
    
    func testFileNotFound() async throws {
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.json")
        
        do {
            _ = try await fileManager.openFile(url: nonExistentURL)
            XCTFail("Should have thrown file not found error")
        } catch FileManagerError.fileNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test Unsupported File Types
    
    func testUnsupportedFileType() async throws {
        let txtFile = tempDirectory.appendingPathComponent("test.txt")
        try "This is a text file".write(to: txtFile, atomically: true, encoding: .utf8)
        
        do {
            _ = try await fileManager.openFile(url: txtFile)
            XCTFail("Should have thrown unsupported file type error")
        } catch FileManagerError.unsupportedFileType {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test Recent Files
    
    func testRecentFilesTracking() async throws {
        let validJSON = "{\"test\": \"value\"}"
        let fileURL = tempDirectory.appendingPathComponent("recent.json")
        try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Initially no recent files
        XCTAssertTrue(fileManager.recentFiles.isEmpty)
        
        // Open file
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
        
        // Should be added to recent files
        XCTAssertEqual(fileManager.recentFiles.count, 1)
        XCTAssertEqual(fileManager.recentFiles.first?.name, "recent.json")
        XCTAssertTrue(fileManager.recentFiles.first?.isValidJSON ?? false)
    }
    
    func testRecentFilesLimit() async throws {
        let validJSON = "{\"test\": \"value\"}"
        
        // Create and open 15 files (more than the 10 file limit)
        for i in 0..<15 {
            let fileURL = tempDirectory.appendingPathComponent("file\(i).json")
            try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
            _ = try await fileManager.openFile(url: fileURL)
        }
        
        // Should only keep 10 recent files
        XCTAssertEqual(fileManager.recentFiles.count, 10)
        
        // Most recent should be file14.json
        XCTAssertEqual(fileManager.recentFiles.first?.name, "file14.json")
    }
    
    func testRecentFilesInvalidJSON() async throws {
        let invalidJSON = "{ invalid json"
        let fileURL = tempDirectory.appendingPathComponent("invalid.json")
        try invalidJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Open invalid file
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertFalse(fileInfo.isValidJSON)
        
        // Should not be added to recent files
        XCTAssertTrue(fileManager.recentFiles.isEmpty)
    }
    
    func testRemoveRecentFile() async throws {
        let validJSON = "{\"test\": \"value\"}"
        let fileURL = tempDirectory.appendingPathComponent("recent.json")
        try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Open file
        _ = try await fileManager.openFile(url: fileURL)
        XCTAssertEqual(fileManager.recentFiles.count, 1)
        
        // Remove from recent files
        if let recentFile = fileManager.recentFiles.first {
            fileManager.removeRecentFile(recentFile)
            XCTAssertTrue(fileManager.recentFiles.isEmpty)
        }
    }
    
    func testClearRecentFiles() async throws {
        let validJSON = "{\"test\": \"value\"}"
        
        // Create and open multiple files
        for i in 0..<5 {
            let fileURL = tempDirectory.appendingPathComponent("file\(i).json")
            try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
            _ = try await fileManager.openFile(url: fileURL)
        }
        
        XCTAssertEqual(fileManager.recentFiles.count, 5)
        
        // Clear all recent files
        fileManager.clearRecentFiles()
        XCTAssertTrue(fileManager.recentFiles.isEmpty)
    }
    
    // MARK: - Test File Content Operations
    
    func testGetFileContent() async throws {
        let content = "{\"test\": \"content\"}"
        let fileURL = tempDirectory.appendingPathComponent("content.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let retrievedContent = try await fileManager.getFileContent(url: fileURL)
        XCTAssertEqual(retrievedContent, content)
    }
    
    func testSaveFile() async throws {
        let content = "{\"saved\": \"content\"}"
        let fileURL = tempDirectory.appendingPathComponent("save.json")
        
        try await fileManager.saveFile(url: fileURL, content: content)
        
        let savedContent = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertEqual(savedContent, content)
    }
    
    // MARK: - Test Error Handling
    
    func testErrorHandling() {
        let error = FileManagerError.invalidJSON("Test error")
        fileManager.setError(error)
        
        XCTAssertEqual(fileManager.errorMessage, "Invalid JSON: Test error")
        
        fileManager.clearError()
        XCTAssertNil(fileManager.errorMessage)
    }
    
    // MARK: - Test File Info Properties
    
    func testFileInfoProperties() async throws {
        let content = "{\"test\": \"properties\"}"
        let fileURL = tempDirectory.appendingPathComponent("properties.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        
        XCTAssertEqual(fileInfo.name, "properties.json")
        XCTAssertGreaterThan(fileInfo.size, 0)
        XCTAssertNotNil(fileInfo.modifiedDate)
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertFalse(fileInfo.formattedSize.isEmpty)
        XCTAssertFalse(fileInfo.formattedModifiedDate.isEmpty)
    }
    
    // MARK: - Test Concurrent Operations
    
    func testConcurrentFileOperations() async throws {
        let validJSON = "{\"test\": \"concurrent\"}"
        
        // Create multiple files
        let fileURLs = (0..<5).map { tempDirectory.appendingPathComponent("concurrent\($0).json") }
        
        // Write files concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for url in fileURLs {
                group.addTask {
                    try validJSON.write(to: url, atomically: true, encoding: .utf8)
                }
            }
            try await group.waitForAll()
        }
        
        // Open files concurrently
        try await withThrowingTaskGroup(of: FileInfo.self) { group in
            for url in fileURLs {
                group.addTask {
                    try await self.fileManager.openFile(url: url)
                }
            }
            
            var results: [FileInfo] = []
            for try await fileInfo in group {
                results.append(fileInfo)
            }
            
            XCTAssertEqual(results.count, 5)
            for fileInfo in results {
                XCTAssertTrue(fileInfo.isValidJSON)
            }
        }
    }
    
    // MARK: - Test Edge Cases
    
    func testEmptyObjectJSON() async throws {
        let emptyObject = "{}"
        let fileURL = tempDirectory.appendingPathComponent("emptyobject.json")
        try emptyObject.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
    }
    
    func testEmptyArrayJSON() async throws {
        let emptyArray = "[]"
        let fileURL = tempDirectory.appendingPathComponent("emptyarray.json")
        try emptyArray.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
    }
    
    func testNestedJSON() async throws {
        let nestedJSON = """
        {
            "level1": {
                "level2": {
                    "level3": {
                        "level4": {
                            "deep": true
                        }
                    }
                }
            }
        }
        """
        
        let fileURL = tempDirectory.appendingPathComponent("nested.json")
        try nestedJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
    }
    
    func testUnicodeJSON() async throws {
        let unicodeJSON = """
        {
            "emoji": "🚀",
            "unicode": "测试",
            "special": "café"
        }
        """
        
        let fileURL = tempDirectory.appendingPathComponent("unicode.json")
        try unicodeJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
    }
}
