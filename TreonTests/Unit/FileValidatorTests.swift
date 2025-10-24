//
//  FileValidatorTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
@testable import Treon

final class FileValidatorTests: XCTestCase {
    var fileValidator: FileValidator!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        fileValidator = FileValidator.shared
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }
    
    func testValidateAndLoadFile_validJSON_returnsFileInfo() async throws {
        let testJSON = """
        {
            "name": "test",
            "value": 42,
            "array": [1, 2, 3]
        }
        """
        
        let fileURL = tempDirectory.appendingPathComponent("test.json")
        try testJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileValidator.validateAndLoadFile(url: fileURL)
        
        XCTAssertEqual(fileInfo.name, "test.json")
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.content, testJSON)
        XCTAssertNotNil(fileInfo.url)
        XCTAssertEqual(fileInfo.url?.path, fileURL.path)
    }
    
    func testValidateAndLoadFile_invalidJSON_returnsFileInfoWithError() async throws {
        let invalidJSON = """
        {
            "name": "test",
            "value": 42,
            "array": [1, 2, 3
        }
        """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid.json")
        try invalidJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let fileInfo = try await fileValidator.validateAndLoadFile(url: fileURL)
        
        XCTAssertEqual(fileInfo.name, "invalid.json")
        XCTAssertFalse(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.content, invalidJSON)
    }
    
    func testValidateAndLoadFile_nonexistentFile_throwsError() async {
        let nonexistentURL = tempDirectory.appendingPathComponent("nonexistent.json")
        
        do {
            _ = try await fileValidator.validateAndLoadFile(url: nonexistentURL)
            XCTFail("Expected fileNotFound error")
        } catch FileManagerError.fileNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testValidateAndLoadFile_500MB_accepted() async throws {
        // Create a 500MB file (within 1GB limit)
        let largeContent = String(repeating: "a", count: 500 * 1024 * 1024) // 500MB
        let fileURL = tempDirectory.appendingPathComponent("500mb.json")
        try largeContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // This should succeed with the new 1GB limit
        let result = try await fileValidator.validateAndLoadFile(url: fileURL)
        XCTAssertNotNil(result)
    }

    func testValidateAndLoadFile_largeFile1GB_throwsError() async throws {
        // Create a large file (over 1GB limit)
        let largeContent = String(repeating: "a", count: 1025 * 1024 * 1024) // 1025MB
        let fileURL = tempDirectory.appendingPathComponent("large.json")
        try largeContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        do {
            _ = try await fileValidator.validateAndLoadFile(url: fileURL)
            XCTFail("Expected fileTooLarge error")
        } catch FileManagerError.fileTooLarge {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testValidateJSONContent_validJSON_returnsTrue() {
        let validJSON = """
        {
            "name": "test",
            "value": 42,
            "array": [1, 2, 3]
        }
        """
        
        let isValid = fileValidator.validateJSONContent(validJSON)
        XCTAssertTrue(isValid)
    }
    
    func testValidateJSONContent_invalidJSON_returnsFalse() {
        let invalidJSON = """
        {
            "name": "test",
            "value": 42,
            "array": [1, 2, 3
        }
        """
        
        let isValid = fileValidator.validateJSONContent(invalidJSON)
        XCTAssertFalse(isValid)
    }
    
    func testValidateJSONContent_emptyString_returnsFalse() {
        let isValid = fileValidator.validateJSONContent("")
        XCTAssertFalse(isValid)
    }
    
    func testValidateJSONContent_validArray_returnsTrue() {
        let validArray = """
        [1, 2, 3, "test", {"key": "value"}]
        """
        
        let isValid = fileValidator.validateJSONContent(validArray)
        XCTAssertTrue(isValid)
    }
}
