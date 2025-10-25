//
//  UserSettingsManagerTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-24.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
import AppKit
@testable import Treon

@MainActor
final class UserSettingsManagerTests: XCTestCase {
    
    private var settings: UserSettingsManager!
    private var userDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Get the shared settings manager
        settings = UserSettingsManager.shared
        
        // Reset to defaults before each test to ensure clean state
        settings.resetToDefaults()
    }
    
    override func tearDown() async throws {
        // Reset to defaults after each test to clean up
        settings.resetToDefaults()
        settings = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Window Settings Tests
    
    func testWindowFramePersistence() {
        // Test default window frame
        let defaultFrame = NSRect(x: 100, y: 100, width: 1200, height: 800)
        XCTAssertEqual(settings.windowFrame, defaultFrame)
        
        // Test setting a new frame
        let newFrame = NSRect(x: 200, y: 200, width: 1400, height: 900)
        settings.windowFrame = newFrame
        XCTAssertEqual(settings.windowFrame, newFrame)
    }
    
    func testNavigatorWidthPersistence() {
        // Test default navigator width
        XCTAssertEqual(settings.navigatorWidth, 400)
        
        // Test setting a new width
        settings.navigatorWidth = 500
        XCTAssertEqual(settings.navigatorWidth, 500)
    }
    
    func testNavigatorCollapsedPersistence() {
        // Test default state
        XCTAssertFalse(settings.isNavigatorCollapsed)
        
        // Test toggling
        settings.isNavigatorCollapsed = true
        XCTAssertTrue(settings.isNavigatorCollapsed)
    }
    
    func testNavigatorPinnedPersistence() {
        // Test default state
        XCTAssertFalse(settings.isNavigatorPinned)
        
        // Test toggling
        settings.isNavigatorPinned = true
        XCTAssertTrue(settings.isNavigatorPinned)
    }
    
    // MARK: - JSON Processing Settings Tests
    
    func testMaxDepthPersistence() {
        // Test default max depth
        XCTAssertEqual(settings.maxDepth, 3)
        
        // Test setting new depth
        settings.maxDepth = 15
        XCTAssertEqual(settings.maxDepth, 15)
    }
    
    func testAutoFormatOnOpenPersistence() {
        // Test default state
        XCTAssertFalse(settings.autoFormatOnOpen)
        
        // Test toggling
        settings.autoFormatOnOpen = true
        XCTAssertTrue(settings.autoFormatOnOpen)
    }
    
    func testShowLineNumbersPersistence() {
        // Test default state
        XCTAssertTrue(settings.showLineNumbers)
        
        // Test toggling
        settings.showLineNumbers = false
        XCTAssertFalse(settings.showLineNumbers)
    }
    
    // MARK: - Recent Files Settings Tests
    
    func testClearRecentFilesOnQuitPersistence() {
        // Test default state
        XCTAssertFalse(settings.clearRecentFilesOnQuit)
        
        // Test toggling
        settings.clearRecentFilesOnQuit = true
        XCTAssertTrue(settings.clearRecentFilesOnQuit)
    }
    
    // MARK: - Performance Settings Tests
    
    func testLargeFileThresholdPersistence() {
        // Test default threshold (50MB)
        let defaultThreshold = 50 * 1024 * 1024
        XCTAssertEqual(settings.largeFileThreshold, defaultThreshold)
        
        // Test setting new threshold
        let newThreshold = 100 * 1024 * 1024
        settings.largeFileThreshold = newThreshold
        XCTAssertEqual(settings.largeFileThreshold, newThreshold)
    }
    
    // MARK: - Utility Methods Tests
    
    func testResetToDefaults() {
        // Change some settings
        settings.windowFrame = NSRect(x: 999, y: 999, width: 999, height: 999)
        settings.navigatorWidth = 999
        settings.maxDepth = 999
        settings.autoFormatOnOpen = true
        settings.showLineNumbers = false
        settings.clearRecentFilesOnQuit = true
        settings.largeFileThreshold = 999
        
        // Reset to defaults
        settings.resetToDefaults()
        
        // Verify all settings are back to defaults
        XCTAssertEqual(settings.windowFrame, NSRect(x: 100, y: 100, width: 1200, height: 800))
        XCTAssertEqual(settings.navigatorWidth, 400)
        XCTAssertFalse(settings.isNavigatorCollapsed)
        XCTAssertFalse(settings.isNavigatorPinned)
        XCTAssertEqual(settings.maxDepth, 3)
        XCTAssertFalse(settings.autoFormatOnOpen)
        XCTAssertTrue(settings.showLineNumbers)
        XCTAssertFalse(settings.clearRecentFilesOnQuit)
        XCTAssertEqual(settings.largeFileThreshold, 50 * 1024 * 1024)
    }
    
    func testExportSettings() {
        // Set some custom values
        settings.navigatorWidth = 500
        settings.maxDepth = 15
        settings.autoFormatOnOpen = true
        
        let exported = settings.exportSettings()
        
        // Verify exported data structure
        XCTAssertNotNil(exported["navigatorWidth"] as? CGFloat)
        XCTAssertNotNil(exported["maxDepth"] as? Int)
        XCTAssertNotNil(exported["autoFormatOnOpen"] as? Bool)
        
        // Check windowFrame structure
        let windowFrame = exported["windowFrame"] as? [String: Any]
        XCTAssertNotNil(windowFrame)
        
        // Check if the properties exist (they might be CGFloat or Double)
        XCTAssertNotNil(windowFrame?["x"])
        XCTAssertNotNil(windowFrame?["y"])
        XCTAssertNotNil(windowFrame?["width"])
        XCTAssertNotNil(windowFrame?["height"])
        
        // Verify values
        XCTAssertEqual(exported["navigatorWidth"] as? CGFloat, 500)
        XCTAssertEqual(exported["maxDepth"] as? Int, 15)
        XCTAssertEqual(exported["autoFormatOnOpen"] as? Bool, true)
    }
    
    func testImportSettings() {
        let testSettings: [String: Any] = [
            "navigatorWidth": CGFloat(600),
            "maxDepth": 20,
            "autoFormatOnOpen": true,
            "showLineNumbers": false,
            "clearRecentFilesOnQuit": true,
            "largeFileThreshold": 75 * 1024 * 1024,
            "windowFrame": [
                "x": 150.0,
                "y": 150.0,
                "width": 1300.0,
                "height": 900.0
            ]
        ]
        
        settings.importSettings(testSettings)
        
        // Verify imported values
        XCTAssertEqual(settings.navigatorWidth, 600)
        XCTAssertEqual(settings.maxDepth, 20)
        XCTAssertTrue(settings.autoFormatOnOpen)
        XCTAssertFalse(settings.showLineNumbers)
        XCTAssertTrue(settings.clearRecentFilesOnQuit)
        XCTAssertEqual(settings.largeFileThreshold, 75 * 1024 * 1024)
        XCTAssertEqual(settings.windowFrame, NSRect(x: 150, y: 150, width: 1300, height: 900))
    }
    
    func testImportSettingsPartial() {
        // Test importing only some settings
        let partialSettings: [String: Any] = [
            "navigatorWidth": CGFloat(700),
            "maxDepth": 25
        ]
        
        let originalWidth = settings.navigatorWidth
        let originalDepth = settings.maxDepth
        let originalThreshold = settings.largeFileThreshold
        
        settings.importSettings(partialSettings)
        
        // Verify only specified settings changed
        XCTAssertEqual(settings.navigatorWidth, 700)
        XCTAssertEqual(settings.maxDepth, 25)
        XCTAssertEqual(settings.largeFileThreshold, originalThreshold) // Should remain unchanged
    }
    
    // MARK: - Edge Cases Tests
    
    func testInvalidWindowFrameData() {
        // Test with invalid window frame data
        let invalidSettings: [String: Any] = [
            "windowFrame": "invalid_data"
        ]
        
        let originalFrame = settings.windowFrame
        settings.importSettings(invalidSettings)
        
        // Should remain unchanged
        XCTAssertEqual(settings.windowFrame, originalFrame)
    }
    
    func testBoundaryValues() {
        // Test boundary values for numeric settings
        settings.maxDepth = 1
        XCTAssertEqual(settings.maxDepth, 1)
        
        settings.maxDepth = 50
        XCTAssertEqual(settings.maxDepth, 50)
        
        settings.largeFileThreshold = 1024 * 1024 // 1MB
        XCTAssertEqual(settings.largeFileThreshold, 1024 * 1024)
        
        settings.largeFileThreshold = 100 * 1024 * 1024 // 100MB
        XCTAssertEqual(settings.largeFileThreshold, 100 * 1024 * 1024)
    }
    
    func testSettingsPersistenceAcrossInstances() {
        // This test would require creating a new instance of UserSettingsManager
        // to verify that settings persist across app launches
        // For now, we'll test that the singleton pattern works
        let settings1 = UserSettingsManager.shared
        let settings2 = UserSettingsManager.shared
        
        XCTAssertTrue(settings1 === settings2, "UserSettingsManager should be a singleton")
    }
}
