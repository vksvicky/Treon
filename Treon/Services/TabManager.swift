//
//  TabManager.swift
//  Treon
//
//  Created by AI Assistant on 2024-12-19.
//  Copyright © 2024 Treon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os.log

/// Represents a tab in the application
struct TabInfo: Identifiable, Equatable {
    let id = UUID()
    let fileInfo: FileInfo
    let isActive: Bool
    
    var name: String {
        fileInfo.name
    }
    
    var url: URL? {
        fileInfo.url
    }
    
    static func == (lhs: TabInfo, rhs: TabInfo) -> Bool {
        lhs.id == rhs.id
    }
}

/// Manages multiple open files as tabs
@MainActor
class TabManager: ObservableObject {
    static let shared = TabManager()
    
    private let logger = Logger(subsystem: "com.treon.app", category: "TabManager")
    
    @Published var tabs: [TabInfo] = []
    @Published var activeTabId: UUID?
    
    private init() {
        logger.info("Initializing TabManager")
    }
    
    // MARK: - Tab Management
    
    /// Opens a new file as a tab
    func openFile(_ fileInfo: FileInfo) {
        logger.info("Opening file as tab: \(fileInfo.name)")
        
        // Check if file is already open
        if let existingTab = tabs.first(where: { $0.url == fileInfo.url }) {
            logger.info("File already open, switching to existing tab")
            switchToTab(existingTab.id)
            return
        }
        
        // Create new tab
        let newTab = TabInfo(fileInfo: fileInfo, isActive: true)
        
        // Deactivate all existing tabs
        tabs = tabs.map { TabInfo(fileInfo: $0.fileInfo, isActive: false) }
        
        // Add new tab and make it active
        tabs.append(newTab)
        activeTabId = newTab.id
        
        logger.info("Opened new tab: \(fileInfo.name), total tabs: \(self.tabs.count)")
    }
    
    /// Switches to a specific tab
    func switchToTab(_ tabId: UUID) {
        logger.info("Switching to tab: \(tabId)")
        
        // Update all tabs to set the correct active state
        tabs = tabs.map { tab in
            TabInfo(fileInfo: tab.fileInfo, isActive: tab.id == tabId)
        }
        
        activeTabId = tabId
    }
    
    /// Closes a specific tab
    func closeTab(_ tabId: UUID) {
        logger.info("Closing tab: \(tabId)")
        
        guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else {
            logger.warning("Tab not found for closing: \(tabId)")
            return
        }
        
        let wasActive = tabs[tabIndex].isActive
        tabs.remove(at: tabIndex)
        
        // If we closed the active tab, switch to another tab
        if wasActive && !tabs.isEmpty {
            // Switch to the tab at the same index, or the last tab if we removed the last one
            let newActiveIndex = min(tabIndex, tabs.count - 1)
            switchToTab(tabs[newActiveIndex].id)
        } else if tabs.isEmpty {
            activeTabId = nil
        }
        
        logger.info("Closed tab, remaining tabs: \(self.tabs.count)")
    }
    
    /// Closes all tabs
    func closeAllTabs() {
        logger.info("Closing all tabs")
        tabs.removeAll()
        activeTabId = nil
    }
    
    /// Gets the currently active tab
    var activeTab: TabInfo? {
        tabs.first { $0.isActive }
    }
    
    /// Gets the currently active file info
    var activeFileInfo: FileInfo? {
        activeTab?.fileInfo
    }
    
    /// Updates the file info for a specific tab
    func updateFileInfo(for tabId: UUID, with newFileInfo: FileInfo) {
        logger.info("Updating file info for tab: \(tabId)")
        
        guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else {
            logger.warning("Tab not found for updating: \(tabId)")
            return
        }
        
        let wasActive = tabs[tabIndex].isActive
        tabs[tabIndex] = TabInfo(fileInfo: newFileInfo, isActive: wasActive)
    }
    
    /// Gets the tab count
    var tabCount: Int {
        tabs.count
    }
    
    /// Checks if there are any open tabs
    var hasOpenTabs: Bool {
        !tabs.isEmpty
    }
}
