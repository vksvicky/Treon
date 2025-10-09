//
//  DirectoryManagerTests.swift
//  TreonTests
//
//  Created by AI Assistant on 2024-12-19.
//  Copyright © 2024 Treon. All rights reserved.
//

import XCTest
@testable import Treon

final class DirectoryManagerTests: XCTestCase {
    var directoryManager: DirectoryManager!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        directoryManager = DirectoryManager.shared
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        // Clear any test data from UserDefaults
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastOpenedDirectory)
        super.tearDown()
    }
    
    func testGetLastOpenedDirectory_returnsDocumentsWhenNoSavedDirectory() {
        // Clear any existing directory memory
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastOpenedDirectory)
        
        let directory = directoryManager.getLastOpenedDirectory()
        
        // Should return Documents directory as fallback
        let expectedDocuments = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        XCTAssertEqual(directory.path, expectedDocuments.path)
    }
    
    func testGetLastOpenedDirectory_returnsSavedDirectoryWhenValid() async {
        // Create a test directory and save it
        let testDir = tempDirectory.appendingPathComponent("testDir")
        try! FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        
        let testData = testDir.dataRepresentation
        UserDefaults.standard.set(testData, forKey: UserDefaultsKeys.lastOpenedDirectory)
        
        let directory = directoryManager.getLastOpenedDirectory()
        
        XCTAssertEqual(directory.path, testDir.path)
    }
    
    func testGetLastOpenedDirectory_returnsDocumentsWhenSavedDirectoryInvalid() async {
        // Save an invalid directory path
        let invalidPath = "/nonexistent/directory/path"
        let invalidURL = URL(fileURLWithPath: invalidPath)
        let invalidData = invalidURL.dataRepresentation
        UserDefaults.standard.set(invalidData, forKey: UserDefaultsKeys.lastOpenedDirectory)
        
        let directory = directoryManager.getLastOpenedDirectory()
        
        // Should fall back to Documents directory
        let expectedDocuments = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        XCTAssertEqual(directory.path, expectedDocuments.path)
        
        // Should also clear the invalid directory from UserDefaults
        let savedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.lastOpenedDirectory)
        XCTAssertNil(savedData)
    }
    
    func testSaveLastOpenedDirectory_savesCorrectDirectory() async {
        // Create a test file in a specific directory
        let testDir = tempDirectory.appendingPathComponent("saveTest")
        try! FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        
        let testFile = testDir.appendingPathComponent("test.json")
        let testJSON = """
        {"test": "data"}
        """
        try! testJSON.write(to: testFile, atomically: true, encoding: .utf8)
        
        // Save the directory
        directoryManager.saveLastOpenedDirectory(url: testFile)
        
        // Verify the directory was saved
        let savedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.lastOpenedDirectory)
        XCTAssertNotNil(savedData)
        
        let savedURL = URL(dataRepresentation: savedData!, relativeTo: nil)
        XCTAssertEqual(savedURL?.path, testDir.path)
    }
    
    func testClearLastOpenedDirectory_removesSavedDirectory() async {
        // Save a directory first
        let testDir = tempDirectory.appendingPathComponent("clearTest")
        try! FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        
        let testData = testDir.dataRepresentation
        UserDefaults.standard.set(testData, forKey: UserDefaultsKeys.lastOpenedDirectory)
        
        // Verify it's saved
        let savedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.lastOpenedDirectory)
        XCTAssertNotNil(savedData)
        
        // Clear it
        directoryManager.clearLastOpenedDirectory()
        
        // Verify it's cleared
        let clearedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.lastOpenedDirectory)
        XCTAssertNil(clearedData)
    }
}
