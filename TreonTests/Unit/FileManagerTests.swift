//
//  FileManagerTests.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

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
        fileManager.clearAllRecentFiles()
    }

    override func tearDown() {
        // Clean up temp directory
        try? FileManager.default.removeItem(at: tempDirectory)
        fileManager.clearAllRecentFiles()
        super.tearDown()
    }

    // MARK: - Test File Creation
    func testCreateNewFile_initialContentValidJSON() {
        let fileInfo = fileManager.createNewFile()

        XCTAssertEqual(fileInfo.name, "Untitled.json")
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertGreaterThan(fileInfo.size, 0)
    }

    // MARK: - Test JSON Validation
    func testOpenFile_validJSON_returnsValid() async throws {
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

    func testOpenFile_validJSONArray_returnsValid() async throws {
        let validJSONArray = """
        [
            {
                "_id": "68e4117f5c89dd802ede80ee",
                "index": 0,
                "isActive": true,
                "balance": "$1,639.30",
                "tags": ["sunt", "dolore", "tempor"]
            },
            {
                "_id": "68e4117f8bce8ebe82f3f7df",
                "index": 1,
                "isActive": false,
                "balance": "$1,949.59",
                "tags": ["adipisicing", "pariatur", "eiusmod"]
            }
        ]
        """
        let fileURL = tempDirectory.appendingPathComponent("array.json")
        try validJSONArray.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)

        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertEqual(fileInfo.name, "array.json")
    }

    func testOpenFile_simpleJSONArray_returnsValid() async throws {
        let simpleArray = "[1, 2, 3, \"hello\", true, null]"
        let fileURL = tempDirectory.appendingPathComponent("simple_array.json")
        try simpleArray.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)

        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertEqual(fileInfo.name, "simple_array.json")
    }

    func testOpenFile_emptyJSONArray_returnsValid() async throws {
        let emptyArray = "[]"
        let fileURL = tempDirectory.appendingPathComponent("empty_array.json")
        try emptyArray.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)

        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertEqual(fileInfo.name, "empty_array.json")
    }

    func testOpenFile_nestedJSONArrays_returnsValid() async throws {
        let nestedArrays = """
        [
            [1, 2, 3],
            ["a", "b", "c"],
            [true, false, null],
            [
                {"name": "John"},
                {"name": "Jane"}
            ]
        ]
        """
        let fileURL = tempDirectory.appendingPathComponent("nested_arrays.json")
        try nestedArrays.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)

        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertNil(fileInfo.errorMessage)
        XCTAssertEqual(fileInfo.name, "nested_arrays.json")
    }

    func testOpenFile_invalidJSON_setsErrorMessage() async throws {
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

    func testOpenFile_emptyJSON_setsErrorMessage() async throws {
        let emptyJSON = ""

        let fileURL = tempDirectory.appendingPathComponent("empty.json")
        try emptyJSON.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)

        XCTAssertFalse(fileInfo.isValidJSON)
        XCTAssertNotNil(fileInfo.errorMessage)
    }

    func testOpenFile_nonJSONContent_setsErrorMessage() async throws {
        let nonJSON = "This is not JSON content"

        let fileURL = tempDirectory.appendingPathComponent("notjson.json")
        try nonJSON.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)

        XCTAssertFalse(fileInfo.isValidJSON)
        XCTAssertNotNil(fileInfo.errorMessage)
    }

    // Size-focused tests moved to FileManagerSizeTests.swift
    // MARK: - Test File Size Limits
    func testOpenFile_accepts500MB_within1GBLimit() async throws {
        // Create a 500MB file (within 1GB limit)
        let largeContent = String(repeating: "a", count: 500 * 1024 * 1024) // 500MB

        let fileURL = tempDirectory.appendingPathComponent("500mb.json")
        try largeContent.write(to: fileURL, atomically: true, encoding: .utf8)

        // This should succeed with the new 1GB limit
        let result = try await fileManager.openFile(url: fileURL)
        XCTAssertNotNil(result)
    }

    func testOpenFile_rejectsOver1GBMaxSize() async throws {
        // Create a file larger than 1GB limit
        let largeContent = String(repeating: "a", count: 1025 * 1024 * 1024) // 1025MB

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
    func testOpenFile_nonexistentURL_throwsFileNotFound() async throws {
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
    func testOpenFile_unsupportedExtension_throws() async throws {
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

    func testRecentFiles_addedOnValidOpen() async throws {
        let validJSON = "{\"test\": \"value\"}"
        let fileURL = tempDirectory.appendingPathComponent("recent.json")
        try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)

        // Initially no recent files
        await MainActor.run {
            XCTAssertTrue(fileManager.recentFiles.isEmpty)
        }

        // Open file
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)

        // Should be added to recent files
        await MainActor.run {
            XCTAssertEqual(fileManager.recentFiles.count, 1)
            XCTAssertEqual(fileManager.recentFiles.first?.name, "recent.json")
            XCTAssertTrue(fileManager.recentFiles.first?.isValidJSON ?? false)
        }
    }

    func testRecentFiles_cappedAtMax() async throws {
        let validJSON = "{\"test\": \"value\"}"

        // Create and open 15 files (more than the 10 file limit)
        for i in 0..<15 {
            let fileURL = tempDirectory.appendingPathComponent("file\(i).json")
            try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
            _ = try await fileManager.openFile(url: fileURL)
        }

        // Give a moment for recent files to be updated
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Should only keep 10 recent files
        await MainActor.run {
            XCTAssertEqual(fileManager.recentFiles.count, 10, "Should have exactly 10 recent files, but got \(fileManager.recentFiles.count)")

            // Most recent should be file14.json
            XCTAssertEqual(fileManager.recentFiles.first?.name, "file14.json")
        }
    }

    func testRecentFiles_notAddedForInvalidJSON() async throws {
        let invalidJSON = "{ invalid json"
        let fileURL = tempDirectory.appendingPathComponent("invalid.json")
        try invalidJSON.write(to: fileURL, atomically: true, encoding: .utf8)

        // Open invalid file
        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertFalse(fileInfo.isValidJSON)

        // Should not be added to recent files
        await MainActor.run {
            XCTAssertTrue(fileManager.recentFiles.isEmpty)
        }
    }

    func testRecentFiles_removeEntry() async throws {
        let validJSON = "{\"test\": \"value\"}"
        let fileURL = tempDirectory.appendingPathComponent("recent.json")
        try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)

        // Open file
        _ = try await fileManager.openFile(url: fileURL)
        await MainActor.run {
            XCTAssertEqual(fileManager.recentFiles.count, 1)
        }

        // Remove from recent files
        await MainActor.run {
            if let recentFile = fileManager.recentFiles.first {
                fileManager.removeRecentFile(recentFile)
                XCTAssertTrue(fileManager.recentFiles.isEmpty)
            }
        }
    }

    func testRecentFiles_clearAll() async throws {
        let validJSON = "{\"test\": \"value\"}"

        // Create and open multiple files
        for i in 0..<5 {
            let fileURL = tempDirectory.appendingPathComponent("file\(i).json")
            try validJSON.write(to: fileURL, atomically: true, encoding: .utf8)
            _ = try await fileManager.openFile(url: fileURL)
        }

        await MainActor.run {
            XCTAssertEqual(fileManager.recentFiles.count, 5)
        }

        // Clear all recent files
        await MainActor.run {
            fileManager.clearAllRecentFiles()
            XCTAssertTrue(fileManager.recentFiles.isEmpty)
        }
    }

    // MARK: - Test File Content Operations
    func testGetFileContent_returnsContent() async throws {
        let content = "{\"test\": \"content\"}"
        let fileURL = tempDirectory.appendingPathComponent("content.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        let retrievedContent = try await fileManager.getFileContent(url: fileURL)
        XCTAssertEqual(retrievedContent, content)
    }

    func testSaveFile_writesContent() async throws {
        let content = "{\"saved\": \"content\"}"
        let fileURL = tempDirectory.appendingPathComponent("save.json")

        try await fileManager.saveFile(url: fileURL, content: content)

        let savedContent = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertEqual(savedContent, content)
    }

    // MARK: - Test Error Handling
    func testSetError_invalidJSON_setsMessage() {
        let error = FileManagerError.invalidJSON("Test error")
        fileManager.setError(error)

        XCTAssertEqual(fileManager.errorMessage, "Invalid JSON: Test error")

        fileManager.clearError()
        XCTAssertNil(fileManager.errorMessage)
    }

    // MARK: - Test File Info Properties
    func testFileInfo_populatedFields() async throws {
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
    func testOpenFiles_concurrently_allValid() async throws {
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

    func testOpenFile_emptyObject_valid() async throws {
        let emptyObject = "{}"
        let fileURL = tempDirectory.appendingPathComponent("emptyobject.json")
        try emptyObject.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
    }

    func testOpenFile_emptyArray_valid() async throws {
        let emptyArray = "[]"
        let fileURL = tempDirectory.appendingPathComponent("emptyarray.json")
        try emptyArray.write(to: fileURL, atomically: true, encoding: .utf8)

        let fileInfo = try await fileManager.openFile(url: fileURL)
        XCTAssertTrue(fileInfo.isValidJSON)
    }

    func testOpenFile_nestedJSON_valid() async throws {
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

    func testOpenFile_unicodeCharacters_valid() async throws {
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
