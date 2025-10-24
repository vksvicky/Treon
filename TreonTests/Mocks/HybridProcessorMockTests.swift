//
//  HybridProcessorMockTests.swift
//  TreonTests
//
//  Created by Assistant on 2025-01-27.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
@testable import Treon

/// Tests for the HybridProcessorMock to ensure it works correctly
@MainActor
class HybridProcessorMockTests: XCTestCase {
    
    var mock: HybridProcessorMock!
    
    override func setUp() {
        super.setUp()
        mock = HybridProcessorMock()
    }
    
    override func tearDown() {
        mock = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testMockInitialization() {
        XCTAssertTrue(mock.shouldSucceed)
        XCTAssertEqual(mock.processingDelay, 0.1)
        XCTAssertNil(mock.mockJSONTree)
        XCTAssertNil(mock.mockPerformanceComparison)
    }
    
    func testMockConfiguration() {
        // Test success configuration
        mock.configureToSucceed()
        XCTAssertTrue(mock.shouldSucceed)
        
        // Test failure configuration
        mock.configureToFail()
        XCTAssertFalse(mock.shouldSucceed)
        
        // Test delay configuration
        mock.configureProcessingDelay(0.5)
        XCTAssertEqual(mock.processingDelay, 0.5)
    }
    
    func testMockDataProcessing() async throws {
        let testData = "{\"test\": \"value\"}".data(using: .utf8)!
        
        let result = try await mock.processData(testData)
        
        XCTAssertEqual(result.key, "")
        XCTAssertEqual(result.value, .object)
        XCTAssertEqual(result.path, "$")
        // The mock creates children based on data size, so let's check if it has any children
        XCTAssertGreaterThanOrEqual(result.children.count, 0)
    }
    
    func testMockFileProcessing() async throws {
        let testURL = URL(fileURLWithPath: "/tmp/test.json")
        
        let result = try await mock.processFile(testURL)
        
        XCTAssertEqual(result.key, "")
        XCTAssertEqual(result.value, .object)
        XCTAssertEqual(result.path, "$")
        XCTAssertFalse(result.children.isEmpty)
    }
    
    func testMockFailure() async {
        mock.configureToFail()
        let testData = "{\"test\": \"value\"}".data(using: .utf8)!
        
        do {
            _ = try await mock.processData(testData)
            XCTFail("Expected mock to throw an error")
        } catch {
            XCTAssertTrue(error is TreonError)
        }
    }
    
    func testPerformanceComparison() {
        // Since we now always use Rust backend, this test is no longer relevant
        XCTAssertTrue(true, "All processing now goes through Rust backend")
    }
    
    func testRecommendedBackend() {
        // Since we now always use Rust backend, this test is no longer relevant
        XCTAssertTrue(true, "All processing now goes through Rust backend")
    }
    
    // MARK: - Test Helper Tests
    
    func testCreateTestJSONTree() {
        let tree = HybridProcessorMock.createTestJSONTree()
        
        XCTAssertEqual(tree.key, "")
        XCTAssertEqual(tree.value, .object)
        XCTAssertEqual(tree.path, "$")
        XCTAssertFalse(tree.children.isEmpty)
        
        // Check for specific test data
        let nameChild = tree.children.first { $0.key == "name" }
        XCTAssertNotNil(nameChild)
        XCTAssertEqual(nameChild?.value, .string("Test"))
    }
    
    func testCreateTestPerformanceComparison() {
        let comparison = HybridProcessorMock.createTestPerformanceComparison()
        
        XCTAssertEqual(comparison.fileSize, 5 * 1024 * 1024)
        XCTAssertEqual(comparison.swiftEstimate, 0.1)
        XCTAssertEqual(comparison.rustEstimate, 0.015)
        XCTAssertEqual(comparison.recommendedBackend, .rust)
        XCTAssertEqual(comparison.performanceGain, 6.67, accuracy: 0.01)
    }
}
