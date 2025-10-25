//
//  UserSettingsManager.swift
//  Treon
//
//  Created by Vivek on 2025-10-24.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import AppKit
import Combine
import os

/// Manages persistent user settings and preferences
@MainActor
class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()
    
    private let userDefaults = UserDefaults.standard
    private let logger = Loggers.ui
    
    // MARK: - Window Settings
    @Published var windowFrame: NSRect {
        didSet {
            saveWindowFrame()
        }
    }
    
    @Published var navigatorWidth: CGFloat {
        didSet {
            saveNavigatorWidth()
        }
    }
    
    @Published var isNavigatorCollapsed: Bool {
        didSet {
            saveNavigatorCollapsed()
        }
    }
    
    @Published var isNavigatorPinned: Bool {
        didSet {
            saveNavigatorPinned()
        }
    }
    
    // MARK: - JSON Processing Settings
    @Published var maxDepth: Int {
        didSet {
            saveMaxDepth()
        }
    }
    
    @Published var autoFormatOnOpen: Bool {
        didSet {
            saveAutoFormatOnOpen()
        }
    }
    
    @Published var showLineNumbers: Bool {
        didSet {
            saveShowLineNumbers()
        }
    }
    
    @Published var wrapText: Bool {
        didSet {
            saveWrapText()
        }
    }
    
    // MARK: - Recent Files Settings
    
    @Published var clearRecentFilesOnQuit: Bool {
        didSet {
            saveClearRecentFilesOnQuit()
        }
    }
    
    // MARK: - Performance Settings
    
    @Published var largeFileThreshold: Int {
        didSet {
            saveLargeFileThreshold()
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Load window settings
        self.windowFrame = Self.loadWindowFrame()
        self.navigatorWidth = Self.loadNavigatorWidth()
        self.isNavigatorCollapsed = Self.loadNavigatorCollapsed()
        self.isNavigatorPinned = Self.loadNavigatorPinned()
        
        // Load JSON processing settings
        self.maxDepth = Self.loadMaxDepth()
        self.autoFormatOnOpen = Self.loadAutoFormatOnOpen()
        self.showLineNumbers = Self.loadShowLineNumbers()
        self.wrapText = Self.loadWrapText()
        
        // Load recent files settings
        self.clearRecentFilesOnQuit = Self.loadClearRecentFilesOnQuit()
        
        // Load performance settings
        self.largeFileThreshold = Self.loadLargeFileThreshold()
        
        logger.info("UserSettingsManager initialized with saved preferences")
    }
    
    // MARK: - Window Settings
    private func saveWindowFrame() {
        let frameData = [
            "x": windowFrame.origin.x,
            "y": windowFrame.origin.y,
            "width": windowFrame.size.width,
            "height": windowFrame.size.height
        ]
        userDefaults.set(frameData, forKey: "windowFrame")
        logger.debug("Saved window frame: x=\(self.windowFrame.origin.x), y=\(self.windowFrame.origin.y), w=\(self.windowFrame.size.width), h=\(self.windowFrame.size.height)")
    }
    
    private static func loadWindowFrame() -> NSRect {
        guard let frameData = UserDefaults.standard.dictionary(forKey: "windowFrame"),
              let x = frameData["x"] as? Double,
              let y = frameData["y"] as? Double,
              let width = frameData["width"] as? Double,
              let height = frameData["height"] as? Double else {
            // Default window frame
            return NSRect(x: 100, y: 100, width: 1200, height: 800)
        }
        return NSRect(x: x, y: y, width: width, height: height)
    }
    
    private func saveNavigatorWidth() {
        userDefaults.set(navigatorWidth, forKey: "navigatorWidth")
        logger.debug("Saved navigator width: \(self.navigatorWidth)")
    }
    
    private static func loadNavigatorWidth() -> CGFloat {
        let saved = UserDefaults.standard.double(forKey: "navigatorWidth")
        return saved > 0 ? saved : 400 // Default width
    }
    
    private func saveNavigatorCollapsed() {
        userDefaults.set(isNavigatorCollapsed, forKey: "isNavigatorCollapsed")
        logger.debug("Saved navigator collapsed: \(self.isNavigatorCollapsed)")
    }
    
    private static func loadNavigatorCollapsed() -> Bool {
        return UserDefaults.standard.bool(forKey: "isNavigatorCollapsed")
    }
    
    private func saveNavigatorPinned() {
        userDefaults.set(isNavigatorPinned, forKey: "isNavigatorPinned")
        logger.debug("Saved navigator pinned: \(self.isNavigatorPinned)")
    }
    
    private static func loadNavigatorPinned() -> Bool {
        return UserDefaults.standard.bool(forKey: "isNavigatorPinned")
    }
    
    // MARK: - JSON Processing Settings
    private func saveMaxDepth() {
        userDefaults.set(maxDepth, forKey: "maxDepth")
        logger.debug("Saved max depth: \(self.maxDepth)")
    }
    
    private static func loadMaxDepth() -> Int {
        let saved = UserDefaults.standard.integer(forKey: "maxDepth")
        return saved >= 0 ? saved : 3 // Default depth (0 = unlimited, 3 = default)
    }
    
    
    private func saveAutoFormatOnOpen() {
        userDefaults.set(autoFormatOnOpen, forKey: "autoFormatOnOpen")
        logger.debug("Saved auto format on open: \(self.autoFormatOnOpen)")
    }
    
    private static func loadAutoFormatOnOpen() -> Bool {
        return UserDefaults.standard.bool(forKey: "autoFormatOnOpen")
    }
    
    private func saveShowLineNumbers() {
        userDefaults.set(showLineNumbers, forKey: "showLineNumbers")
        logger.debug("Saved show line numbers: \(self.showLineNumbers)")
    }
    
    private static func loadShowLineNumbers() -> Bool {
        return UserDefaults.standard.bool(forKey: "showLineNumbers")
    }
    
    private func saveWrapText() {
        userDefaults.set(wrapText, forKey: "wrapText")
        logger.debug("Saved wrap text: \(self.wrapText)")
    }
    
    private static func loadWrapText() -> Bool {
        return UserDefaults.standard.bool(forKey: "wrapText")
    }
    
    // MARK: - Recent Files Settings
    
    private func saveClearRecentFilesOnQuit() {
        userDefaults.set(clearRecentFilesOnQuit, forKey: "clearRecentFilesOnQuit")
        logger.debug("Saved clear recent files on quit: \(self.clearRecentFilesOnQuit)")
    }
    
    private static func loadClearRecentFilesOnQuit() -> Bool {
        return UserDefaults.standard.bool(forKey: "clearRecentFilesOnQuit")
    }
    
    // MARK: - Performance Settings
    
    private func saveLargeFileThreshold() {
        userDefaults.set(largeFileThreshold, forKey: "largeFileThreshold")
        logger.debug("Saved large file threshold: \(self.largeFileThreshold)")
    }
    
    private static func loadLargeFileThreshold() -> Int {
        let saved = UserDefaults.standard.integer(forKey: "largeFileThreshold")
        return saved > 0 ? saved : 50 * 1024 * 1024 // Default 50MB
    }
    
    // MARK: - Utility Methods
    func resetToDefaults() {
        logger.info("Resetting all settings to defaults")
        
        // Reset window settings
        windowFrame = NSRect(x: 100, y: 100, width: 1200, height: 800)
        navigatorWidth = 400
        isNavigatorCollapsed = false
        isNavigatorPinned = false
        
        // Reset JSON processing settings
        maxDepth = 3
        autoFormatOnOpen = false
        showLineNumbers = true
        wrapText = false
        
        // Reset recent files settings
        clearRecentFilesOnQuit = false
        
        // Reset performance settings
        largeFileThreshold = 50 * 1024 * 1024
    }
    
    func exportSettings() -> [String: Any] {
        return [
            "windowFrame": [
                "x": windowFrame.origin.x,
                "y": windowFrame.origin.y,
                "width": windowFrame.size.width,
                "height": windowFrame.size.height
            ],
            "navigatorWidth": navigatorWidth,
            "isNavigatorCollapsed": isNavigatorCollapsed,
            "isNavigatorPinned": isNavigatorPinned,
            "maxDepth": maxDepth,
            "autoFormatOnOpen": autoFormatOnOpen,
            "showLineNumbers": showLineNumbers,
            "wrapText": wrapText,
            "clearRecentFilesOnQuit": clearRecentFilesOnQuit,
            "largeFileThreshold": largeFileThreshold
        ]
    }
    
    func importSettings(_ settings: [String: Any]) {
        logger.info("Importing settings")
        
        // Import window settings
        if let frameData = settings["windowFrame"] as? [String: Double],
           let x = frameData["x"], let y = frameData["y"],
           let width = frameData["width"], let height = frameData["height"] {
            windowFrame = NSRect(x: x, y: y, width: width, height: height)
        }
        
        if let width = settings["navigatorWidth"] as? CGFloat {
            navigatorWidth = width
        }
        if let collapsed = settings["isNavigatorCollapsed"] as? Bool {
            isNavigatorCollapsed = collapsed
        }
        if let pinned = settings["isNavigatorPinned"] as? Bool {
            isNavigatorPinned = pinned
        }
        
        // Import other settings...
        if let depth = settings["maxDepth"] as? Int {
            maxDepth = depth
        }
        if let autoFormat = settings["autoFormatOnOpen"] as? Bool {
            autoFormatOnOpen = autoFormat
        }
        if let lineNumbers = settings["showLineNumbers"] as? Bool {
            showLineNumbers = lineNumbers
        }
        if let wrap = settings["wrapText"] as? Bool {
            wrapText = wrap
        }
        if let clearOnQuit = settings["clearRecentFilesOnQuit"] as? Bool {
            clearRecentFilesOnQuit = clearOnQuit
        }
        if let threshold = settings["largeFileThreshold"] as? Int {
            largeFileThreshold = threshold
        }
    }
}
