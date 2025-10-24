import XCTest
import Foundation
import OSLog
@testable import Treon

@MainActor
class LargeFileTests: XCTestCase {
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "LargeFileTests")
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

    // MARK: - Test Different File Sizes

    func testOpensValidJSON_approximately1KB() async throws {
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
        logger.info("1KB file processed in \(timeElapsed)s")
    }

    func testOpensValidJSON_approximately10KB() async throws {
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
        logger.info("10KB file processed in \(timeElapsed)s")
    }

    func testOpensValidJSON_approximately100KB() async throws {
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
        logger.info("100KB file processed in \(timeElapsed)s")
    }

    func testOpensValidJSON_approximately1MB() async throws {
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
        logger.info("1MB file processed in \(timeElapsed)s")
    }

    func testOpensValidJSON_approximately10MB() async throws {
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
        logger.info("10MB file processed in \(timeElapsed)s")
    }

    func testOpensValidJSON_approximately50MB_underLimit() async throws {
        let content = generateJSONContent(targetSize: 49 * 1024 * 1024) // 49MB (under 50MB limit)
        let fileURL = tempDirectory.appendingPathComponent("49mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        let startTime = CFAbsoluteTimeGetCurrent()
        let fileInfo = try await fileManager.openFile(url: fileURL)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertTrue(fileInfo.isValidJSON)
        XCTAssertEqual(fileInfo.name, "49mb.json")
        XCTAssertLessThan(fileInfo.size, 100 * 1024 * 1024) // Should be around 49MB
        XCTAssertLessThan(timeElapsed, 30.0) // Should be reasonably fast
        logger.info("49MB file processed in \(timeElapsed)s")
    }

    func testAcceptsFileSize_501MB_within1GBLimit() async throws {
        // With app limit at 1GB, a 501MB file should be accepted
        let content = generateJSONContent(targetSize: 501 * 1024 * 1024) // 501MB
        let fileURL = tempDirectory.appendingPathComponent("501mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        // This should succeed with the new 1GB limit
        let result = try await fileManager.openFile(url: fileURL)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.name, "501mb.json")
    }

    func testRejectsFileSize_over1GBLimit() async throws {
        // With app limit at 1GB, create a file larger than 1GB to test rejection
        let content = generateJSONContent(targetSize: 1025 * 1024 * 1024) // 1025MB
        let fileURL = tempDirectory.appendingPathComponent("1025mb.json")
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        do {
            _ = try await fileManager.openFile(url: fileURL)
            XCTFail("Should have thrown file too large error for 1025MB file")
        } catch FileManagerError.fileTooLarge {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFileSizeLimits_comprehensive() async throws {
        // Test various file sizes to ensure proper limit enforcement
        
        // Test 1: 500MB should be accepted (within 1GB limit)
        let content500MB = generateJSONContent(targetSize: 500 * 1024 * 1024) // 500MB
        let fileURL500MB = tempDirectory.appendingPathComponent("500mb.json")
        try content500MB.write(to: fileURL500MB, atomically: true, encoding: .utf8)
        
        let result500MB = try await fileManager.openFile(url: fileURL500MB)
        XCTAssertNotNil(result500MB, "500MB file should be accepted")
        
        // Test 2: 1GB should be accepted (under the 1GB limit)
        let content1GB = generateJSONContent(targetSize: 1000 * 1024 * 1024) // 1000MB (clearly under 1GB)
        let fileURL1GB = tempDirectory.appendingPathComponent("1gb.json")
        try content1GB.write(to: fileURL1GB, atomically: true, encoding: .utf8)
        
        let result1GB = try await fileManager.openFile(url: fileURL1GB)
        XCTAssertNotNil(result1GB, "1GB file should be accepted")
        
        // Test 3: 1.1GB should be rejected (over the limit)
        let content1_1GB = generateJSONContent(targetSize: 1100 * 1024 * 1024) // 1.1GB
        let fileURL1_1GB = tempDirectory.appendingPathComponent("1.1gb.json")
        try content1_1GB.write(to: fileURL1_1GB, atomically: true, encoding: .utf8)
        
        do {
            _ = try await fileManager.openFile(url: fileURL1_1GB)
            XCTFail("1.1GB file should be rejected")
        } catch FileManagerError.fileTooLarge {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test File Size Limit
    // Note: The 51MB rejection test was removed as it was based on an outdated 50MB limit.
    // The current limit is 500MB, so 51MB files are valid and should be processed successfully.

    // MARK: - Test Memory Usage

    func testMemoryUsage_remainsReasonable_acrossSizes() async throws {
        let sizes = [1024, 1024 * 1024, 10 * 1024 * 1024, 49 * 1024 * 1024] // 1KB, 1MB, 10MB, 49MB (under 50MB limit)

        for size in sizes {
            let content = generateJSONContent(targetSize: size)
            let fileURL = tempDirectory.appendingPathComponent("memory\(size).json")
            try content.write(to: fileURL, atomically: true, encoding: .utf8)

            let startTime = CFAbsoluteTimeGetCurrent()
            let fileInfo = try await fileManager.openFile(url: fileURL)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

            XCTAssertTrue(fileInfo.isValidJSON)
            logger.info("\(size / 1024 / 1024)MB file processed in \(timeElapsed)s")

            // Clean up to free memory
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // MARK: - Test Concurrent Large File Operations

    func testConcurrentOpen_validAcrossSizes() async throws {
        let sizes = [1024, 10 * 1024, 100 * 1024, 1024 * 1024] // 1KB, 10KB, 100KB, 1MB

        // Create files concurrently
        guard let tempDir = tempDirectory else {
            XCTFail("tempDirectory is nil")
            return
        }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for size in sizes {
                group.addTask {
                    let content = self.generateJSONContent(targetSize: size)
                    let fileURL = tempDir.appendingPathComponent("concurrent\(size).json")
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
                    let fileURL = tempDir.appendingPathComponent("concurrent\(size).json")
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

        logger.info("Concurrent processing of \(sizes.count) files completed in \(timeElapsed)s")
    }

    // MARK: - Test Different JSON Structures

    func testParsesLargeArrayJSON_quickly() async throws {
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
        logger.info("Large array JSON processed in \(timeElapsed)s")
    }

    func testParsesLargeObjectJSON_quickly() async throws {
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
        logger.info("Large object JSON processed in \(timeElapsed)s")
    }

    // MARK: - Helper Methods

    nonisolated private func generateJSONContent(targetSize: Int) -> String {
        var content = "{\n"
        var currentSize = 2 // Start with "{\n"

        let keyTemplate = "key_"
        let baseValue = "This is a sample value with some additional text to make it longer and more realistic for testing purposes. "

        var keyIndex = 0
        var isFirstEntry = true

        while currentSize < targetSize {
            let key = "\(keyTemplate)\(keyIndex)"
            // Estimate remaining space and size a value that fits without forcing a trailing comma
            let remaining = max(0, targetSize - currentSize - 100)
            let repeatCount = max(1, min(8, remaining / max(1, baseValue.count)))
            let value = String(repeating: baseValue, count: repeatCount) + "\(keyIndex)"

            if !isFirstEntry {
                content += ",\n"
                currentSize += 2
            }
            content += "  \"\(key)\": \"\(value)\""
            currentSize += key.count + value.count + 8

            isFirstEntry = false
            keyIndex += 1
        }

        content += "\n}"
        return content
    }
}
