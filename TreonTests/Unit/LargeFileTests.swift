import XCTest
import Foundation
@testable import Treon

class LargeFileTests: XCTestCase {
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
    
    // MARK: - Test Different File Sizes
    
    func test1KBFile() async throws {
        let content = generateJSONContent(targetSize: 1024) // 1KB
        let fileURL = tempDirectory.appendingPathComponent("1kb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "1kb.json")
        XCTAssertLessThan(fileInfo.size, 2 * 1024) // Should be around 1KB
        XCTAssertLessThan(timeElapsed, 1.0) // Should be very fast
        print("1KB file processed in \(timeElapsed)s")
    }
    
    func test10KBFile() async throws {
        let content = generateJSONContent(targetSize: 10 * 1024) // 10KB
        let fileURL = tempDirectory.appendingPathComponent("10kb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "10kb.json")
        XCTAssertLessThan(fileInfo.size, 20 * 1024) // Should be around 10KB
        XCTAssertLessThan(timeElapsed, 1.0) // Should be fast
        print("10KB file processed in \(timeElapsed)s")
    }
    
    func test100KBFile() async throws {
        let content = generateJSONContent(targetSize: 100 * 1024) // 100KB
        let fileURL = tempDirectory.appendingPathComponent("100kb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "100kb.json")
        XCTAssertLessThan(fileInfo.size, 200 * 1024) // Should be around 100KB
        XCTAssertLessThan(timeElapsed, 2.0) // Should be reasonably fast
        print("100KB file processed in \(timeElapsed)s")
    }
    
    func test1MBFile() async throws {
        let content = generateJSONContent(targetSize: 1024 * 1024) // 1MB
        let fileURL = tempDirectory.appendingPathComponent("1mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "1mb.json")
        XCTAssertLessThan(fileInfo.size, 2 * 1024 * 1024) // Should be around 1MB
        XCTAssertLessThan(timeElapsed, 5.0) // Should be reasonably fast
        print("1MB file processed in \(timeElapsed)s")
    }
    
    func test10MBFile() async throws {
        let content = generateJSONContent(targetSize: 10 * 1024 * 1024) // 10MB
        let fileURL = tempDirectory.appendingPathComponent("10mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "10mb.json")
        XCTAssertLessThan(fileInfo.size, 20 * 1024 * 1024) // Should be around 10MB
        XCTAssertLessThan(timeElapsed, 10.0) // Should be reasonably fast
        print("10MB file processed in \(timeElapsed)s")
    }
    
    func test50MBFile() async throws {
        let content = generateJSONContent(targetSize: 50 * 1024 * 1024) // 50MB
        let fileURL = tempDirectory.appendingPathComponent("50mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "50mb.json")
        XCTAssertLessThan(fileInfo.size, 100 * 1024 * 1024) // Should be around 50MB
        XCTAssertLessThan(timeElapsed, 30.0) // Should be reasonably fast
        print("50MB file processed in \(timeElapsed)s")
    }
    
    func test100MBFile() async throws {
        let content = generateJSONContent(targetSize: 100 * 1024 * 1024) // 100MB
        let fileURL = tempDirectory.appendingPathComponent("100mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "100mb.json")
        XCTAssertLessThan(fileInfo.size, 200 * 1024 * 1024) // Should be around 100MB
        XCTAssertLessThan(timeElapsed, 60.0) // Should be reasonably fast
        print("100MB file processed in \(timeElapsed)s")
    }
    
    // MARK: - Test File Size Limit
    
    func test51MBFileExceedsLimit() async throws {
        let content = generateJSONContent(targetSize: 51 * 1024 * 1024) // 51MB (exceeds 50MB limit)
        let fileURL = tempDirectory.appendingPathComponent("51mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        do {
            _ = try await fileManager.openFile(url: fileURL)
            XCTFail("Should have thrown file too large error")
        } catch FileManagerError.fileTooLarge {
            // Expected error
            print("Correctly rejected 51MB file as too large")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Test Memory Usage
    
    func testMemoryUsageWithLargeFiles() async throws {
        let sizes = [1024, 1024 * 1024, 10 * 1024 * 1024, 50 * 1024 * 1024] // 1KB, 1MB, 10MB, 50MB
        
        for size in sizes {
            let content = generateJSONContent(targetSize: size)
            let fileURL = tempDirectory.appendingPathComponent("memory\(size).json")
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let startTime = CFAbsoluteTimeGetCurrent()
            let fileInfo = try await fileManager.openFile(url: fileURL)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            XCTAssertTrue(fileInfo.isValidJSON)
            print("\(size / 1024 / 1024)MB file processed in \(timeElapsed)s")
            
            // Clean up to free memory
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - Test Concurrent Large File Operations
    
    func testConcurrentLargeFileOperations() async throws {
        let sizes = [1024, 10 * 1024, 100 * 1024, 1024 * 1024] // 1KB, 10KB, 100KB, 1MB
        
        // Create files concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for size in sizes {
                group.addTask {
                    let content = self.generateJSONContent(targetSize: size)
                    let fileURL = self.tempDirectory.appendingPathComponent("concurrent\(size).json")
                    try content.write(to: fileURL, atomically: true, encoding: .utf8)
                }
            }
            try await group.waitForAll()
        }
        
        // Process files concurrently
        let startTime = CFAbsoluteTimeGetCurrent()
        try await withThrowingTaskGroup(of: FileInfo.self) { group in
            for size in sizes {
                group.addTask {
                    let fileURL = self.tempDirectory.appendingPathComponent("concurrent\(size).json")
                    return try await self.fileManager.openFile(url: fileURL)
                }
            }
            
            var results: [FileInfo] = []
            for try await fileInfo in group {
                results.append(fileInfo)
                XCTAssertTrue(fileInfo.isValidJSON)
            }
            
            XCTAssertEqual(results.count, sizes.count)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print("Concurrent processing of \(sizes.count) files completed in \(timeElapsed)s")
    }
    
    // MARK: - Test Different JSON Structures
    
    func testLargeArrayJSON() async throws {
        let arraySize = 100000 // 100k elements
        var jsonContent = "[\n"
        
        for i in 0..<arraySize {
            jsonContent += "  {\n"
            jsonContent += "    \"id\": \(i),\n"
            jsonContent += "    \"name\": \"Item \(i)\",\n"
            jsonContent += "    \"value\": \(i * 2),\n"
            jsonContent += "    \"active\": \(i % 2 == 0)\n"
            jsonContent += "  }"
            if i < arraySize - 1 {
                jsonContent += ","
            }
            jsonContent += "\n"
        }
        jsonContent += "]"
        
        let fileURL = tempDirectory.appendingPathComponent("largearray.json")
        try jsonContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThan(fileInfo.size, 1024 * 1024) // Should be over 1MB
        XCTAssertLessThan(timeElapsed, 10.0) // Should be reasonably fast
        print("Large array JSON processed in \(timeElapsed)s")
    }
    
    func testLargeObjectJSON() async throws {
        let objectCount = 10000 // 10k objects
        var jsonContent = "{\n"
        
        for i in 0..<objectCount {
            jsonContent += "  \"object\(i)\": {\n"
            jsonContent += "    \"id\": \(i),\n"
            jsonContent += "    \"data\": \"This is a long string with some data for object \(i)\",\n"
            jsonContent += "    \"numbers\": [\(i), \(i+1), \(i+2), \(i+3), \(i+4)],\n"
            jsonContent += "    \"nested\": {\n"
            jsonContent += "      \"level1\": {\n"
            jsonContent += "        \"level2\": \"value\(i)\"\n"
            jsonContent += "      }\n"
            jsonContent += "    }\n"
            jsonContent += "  }"
            if i < objectCount - 1 {
                jsonContent += ","
            }
            jsonContent += "\n"
        }
        jsonContent += "}"
        
        let fileURL = tempDirectory.appendingPathComponent("largeobject.json")
        try jsonContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertGreaterThan(fileInfo.size, 1024 * 1024) // Should be over 1MB
        XCTAssertLessThan(timeElapsed, 10.0) // Should be reasonably fast
        print("Large object JSON processed in \(timeElapsed)s")
    }
    
    // MARK: - Helper Methods
    
    private func generateJSONContent(targetSize: Int) -> String {
        var content = "{\n"
        var currentSize = 2 // Start with "{\n"
        
        let keyTemplate = "key_"
        let valueTemplate = "This is a sample value with some additional text to make it longer and more realistic for testing purposes. "
        
        var keyIndex = 0
        
        while currentSize < targetSize {
            let key = "\(keyTemplate)\(keyIndex)"
            let value = "\(valueTemplate)\(keyIndex)"
            
            content += "  \"\(key)\": \"\(value)\""
            currentSize += key.count + value.count + 8 // Account for quotes, colon, spaces
            
            if currentSize < targetSize - 10 { // Leave room for closing brace
                content += ","
                currentSize += 1
            }
            content += "\n"
            currentSize += 1
            
            keyIndex += 1
        }
        
        content += "}"
        return content
    }
}
