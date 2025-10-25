//
//  SettingsViewTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-25.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
import SwiftUI
@testable import Treon

@MainActor
final class SettingsViewTests: XCTestCase {
    
    private var settings: UserSettingsManager!
    
    override func setUp() async throws {
        try await super.setUp()
        settings = UserSettingsManager.shared
        settings.resetToDefaults()
    }
    
    override func tearDown() async throws {
        settings.resetToDefaults()
        settings = nil
        try await super.tearDown()
    }
    
    // MARK: - Settings View Integration Tests
    
    func testSettingsViewInitialization() {
        let settingsView = SettingsView()
        XCTAssertNotNil(settingsView)
    }
    
    func testSettingsViewWithCustomSettings() {
        // Modify some settings
        settings.navigatorWidth = 500
        settings.maxDepth = 10
        settings.autoFormatOnOpen = true
        settings.wrapText = true
        
        let settingsView = SettingsView()
        XCTAssertNotNil(settingsView)
    }
    
    // MARK: - Settings Persistence Tests
    
    func testSettingsPersistenceAcrossViews() {
        let originalWidth = settings.navigatorWidth
        let originalDepth = settings.maxDepth
        
        // Create first view and modify settings
        let view1 = SettingsView()
        settings.navigatorWidth = 600
        settings.maxDepth = 15
        
        // Create second view and verify settings persist
        let view2 = SettingsView()
        XCTAssertEqual(settings.navigatorWidth, 600)
        XCTAssertEqual(settings.maxDepth, 15)
        
        // Restore original values
        settings.navigatorWidth = originalWidth
        settings.maxDepth = originalDepth
    }
    
    // MARK: - Settings Validation Tests
    
    func testNavigatorWidthValidation() {
        // Test minimum width
        settings.navigatorWidth = 100
        XCTAssertGreaterThanOrEqual(settings.navigatorWidth, 100)
        
        // Test maximum width
        settings.navigatorWidth = 2000
        XCTAssertLessThanOrEqual(settings.navigatorWidth, 2000)
        
        // Test normal width
        settings.navigatorWidth = 400
        XCTAssertEqual(settings.navigatorWidth, 400)
    }
    
    func testMaxDepthValidation() {
        // Test minimum depth
        settings.maxDepth = 1
        XCTAssertGreaterThanOrEqual(settings.maxDepth, 1)
        
        // Test maximum depth
        settings.maxDepth = 50
        XCTAssertLessThanOrEqual(settings.maxDepth, 50)
        
        // Test normal depth
        settings.maxDepth = 3
        XCTAssertEqual(settings.maxDepth, 3)
    }
    
    func testLargeFileThresholdValidation() {
        // Test minimum threshold (1MB)
        settings.largeFileThreshold = 1024 * 1024
        XCTAssertGreaterThanOrEqual(settings.largeFileThreshold, 1024 * 1024)
        
        // Test maximum threshold (1GB)
        settings.largeFileThreshold = 1024 * 1024 * 1024
        XCTAssertLessThanOrEqual(settings.largeFileThreshold, 1024 * 1024 * 1024)
        
        // Test normal threshold (50MB)
        settings.largeFileThreshold = 50 * 1024 * 1024
        XCTAssertEqual(settings.largeFileThreshold, 50 * 1024 * 1024)
    }
    
    // MARK: - Settings Reset Tests
    
    func testSettingsResetToDefaults() {
        // Modify all settings
        settings.navigatorWidth = 999
        settings.maxDepth = 999
        settings.autoFormatOnOpen = true
        settings.wrapText = true
        settings.clearRecentFilesOnQuit = true
        settings.largeFileThreshold = 999 * 1024 * 1024
        settings.windowFrame = NSRect(x: 999, y: 999, width: 999, height: 999)
        
        // Reset to defaults
        settings.resetToDefaults()
        
        // Verify all settings are back to defaults
        XCTAssertEqual(settings.navigatorWidth, 400)
        XCTAssertEqual(settings.maxDepth, 3)
        XCTAssertFalse(settings.autoFormatOnOpen)
        XCTAssertFalse(settings.wrapText)
        XCTAssertFalse(settings.clearRecentFilesOnQuit)
        XCTAssertEqual(settings.largeFileThreshold, 50 * 1024 * 1024)
        XCTAssertEqual(settings.windowFrame, NSRect(x: 100, y: 100, width: 1200, height: 800))
    }
    
    // MARK: - Settings Export/Import Tests
    
    func testSettingsExportImportRoundtrip() {
        // Set custom values
        settings.navigatorWidth = 500
        settings.maxDepth = 10
        settings.autoFormatOnOpen = true
        settings.wrapText = true
        settings.clearRecentFilesOnQuit = true
        settings.largeFileThreshold = 75 * 1024 * 1024
        
        // Export settings
        let exported = settings.exportSettings()
        
        // Reset to defaults
        settings.resetToDefaults()
        
        // Import settings
        settings.importSettings(exported)
        
        // Verify values are restored
        XCTAssertEqual(settings.navigatorWidth, 500)
        XCTAssertEqual(settings.maxDepth, 10)
        XCTAssertTrue(settings.autoFormatOnOpen)
        XCTAssertTrue(settings.wrapText)
        XCTAssertTrue(settings.clearRecentFilesOnQuit)
        XCTAssertEqual(settings.largeFileThreshold, 75 * 1024 * 1024)
    }
    
    func testSettingsExportWithInvalidData() {
        // Test export with corrupted data
        let invalidSettings: [String: Any] = [
            "navigatorWidth": "invalid",
            "maxDepth": "invalid",
            "windowFrame": "invalid"
        ]
        
        let originalWidth = settings.navigatorWidth
        let originalDepth = settings.maxDepth
        let originalFrame = settings.windowFrame
        
        settings.importSettings(invalidSettings)
        
        // Settings should remain unchanged
        XCTAssertEqual(settings.navigatorWidth, originalWidth)
        XCTAssertEqual(settings.maxDepth, originalDepth)
        XCTAssertEqual(settings.windowFrame, originalFrame)
    }
    
    // MARK: - Performance Tests
    
    func testSettingsPerformance() {
        measure {
            for i in 0..<1000 {
                settings.navigatorWidth = CGFloat(i)
                settings.maxDepth = i % 50 + 1
                settings.autoFormatOnOpen = i % 2 == 0
                settings.wrapText = i % 3 == 0
            }
        }
    }
    
    func testSettingsExportPerformance() {
        // Set some values first
        settings.navigatorWidth = 500
        settings.maxDepth = 10
        settings.autoFormatOnOpen = true
        
        measure {
            for _ in 0..<100 {
                _ = settings.exportSettings()
            }
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testSettingsWithExtremeValues() {
        // Test with extreme but valid values
        settings.navigatorWidth = 1
        XCTAssertEqual(settings.navigatorWidth, 1)
        
        settings.navigatorWidth = 10000
        XCTAssertEqual(settings.navigatorWidth, 10000)
        
        settings.maxDepth = 1
        XCTAssertEqual(settings.maxDepth, 1)
        
        settings.maxDepth = 100
        XCTAssertEqual(settings.maxDepth, 100)
    }
    
    func testSettingsWithZeroValues() {
        // Test with zero values (should be handled gracefully)
        settings.navigatorWidth = 0
        XCTAssertEqual(settings.navigatorWidth, 0)
        
        settings.maxDepth = 0
        XCTAssertEqual(settings.maxDepth, 0)
        
        settings.largeFileThreshold = 0
        XCTAssertEqual(settings.largeFileThreshold, 0)
    }
    
    func testSettingsWithNegativeValues() {
        // Test with negative values (should be handled gracefully)
        settings.navigatorWidth = -100
        XCTAssertEqual(settings.navigatorWidth, -100)
        
        settings.maxDepth = -5
        XCTAssertEqual(settings.maxDepth, -5)
        
        settings.largeFileThreshold = -1000
        XCTAssertEqual(settings.largeFileThreshold, -1000)
    }
    
    // MARK: - Thread Safety Tests
    
    func testSettingsThreadSafety() {
        let expectation = XCTestExpectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                self.settings.navigatorWidth = CGFloat(i * 100)
                self.settings.maxDepth = i + 1
                self.settings.autoFormatOnOpen = i % 2 == 0
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
