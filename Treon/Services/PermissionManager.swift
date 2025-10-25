//
//  PermissionManager.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import AppKit
import OSLog
import Combine
import UniformTypeIdentifiers
import Security

/// Centralized permission management for file access
class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "PermissionManager")
    private let bookmarkManager = SecurityScopedBookmarkManager.shared

    @Published var hasFileAccessPermission: Bool = false
    @Published var grantedDirectories: [URL] = []
    @Published var permissionStatus: PermissionStatus = .unknown

    enum PermissionStatus {
        case unknown
        case granted
        case denied
        case restricted
        case needsUserAction
    }

    private init() {
        checkFileAccessPermission()
    }

    /// Check if the app has file access permission
    func checkFileAccessPermission() {
        logger.info("Checking file access permissions")
        
        // Check if we have any saved security-scoped bookmarks
        let savedBookmarks = bookmarkManager.loadAllBookmarks()
        
        if savedBookmarks.isEmpty {
            permissionStatus = .needsUserAction
            hasFileAccessPermission = false
            logger.info("No file access permissions found - user action required")
            return
        }
        
        // Test access to saved bookmarks
        var accessibleDirectories: [URL] = []
        
        for (path, bookmarkData) in savedBookmarks {
            if let url = bookmarkManager.resolveBookmark(bookmarkData) {
                if bookmarkManager.startAccessingSecurityScopedResource(url) {
                    accessibleDirectories.append(url)
                    logger.info("Successfully accessing directory: \(url.path)")
                } else {
                    logger.warning("Failed to start accessing directory: \(path)")
                }
            } else {
                logger.warning("Failed to resolve bookmark for: \(path)")
            }
        }
        
        grantedDirectories = accessibleDirectories
        hasFileAccessPermission = !accessibleDirectories.isEmpty
        permissionStatus = self.hasFileAccessPermission ? .granted : .denied
        
        logger.info("File access permission check complete: \(self.hasFileAccessPermission ? "GRANTED" : "DENIED")")
    }

    /// Request file access permission by opening a directory dialog
    func requestFileAccessPermission() async -> Bool {
        logger.info("PermissionManager: Requesting directory access permission")

        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.logger.info("PermissionManager: Creating NSOpenPanel")
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = true
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.title = "Grant Directory Access"
                panel.message = "Select directories that Treon can access to read JSON files. You can select multiple directories."
                panel.prompt = "Grant Access"

                // Use a non-blocking approach to show the panel
                panel.begin { response in
                    if response == .OK {
                    let selectedURLs = panel.urls
                    self.logger.info("User selected \(selectedURLs.count) directories")
                    
                    // Create security-scoped bookmarks for each selected directory
                    var successCount = 0
                    for url in selectedURLs {
                        if let bookmarkData = self.bookmarkManager.createBookmark(for: url) {
                            self.bookmarkManager.saveBookmark(bookmarkData, for: url)
                            successCount += 1
                            self.logger.info("Created and saved bookmark for: \(url.path)")
                        } else {
                            self.logger.error("Failed to create bookmark for: \(url.path)")
                        }
                    }
                    
                    if successCount > 0 {
                        self.checkFileAccessPermission() // Refresh permission status
                        continuation.resume(returning: true)
                    } else {
                        self.logger.error("Failed to create any bookmarks")
                        continuation.resume(returning: false)
                    }
                    } else {
                        self.logger.info("User cancelled directory selection")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }

    /// Open system privacy settings for the app
    func openSystemPrivacySettings() {
        logger.info("Opening system privacy settings")

        // Open System Settings to the Privacy & Security section
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Get a user-friendly permission status message
    var permissionStatusMessage: String {
        switch permissionStatus {
        case .granted:
            if grantedDirectories.count == 1 {
                return "Access granted to: \(grantedDirectories[0].lastPathComponent)"
            } else {
                return "Access granted to \(grantedDirectories.count) directories"
            }
        case .denied:
            return "File access permission was denied"
        case .restricted:
            return "File access is restricted by system"
        case .needsUserAction:
            return "File access permission is required"
        case .unknown:
            return "Checking file access permissions..."
        }
    }
    
    /// Get detailed permission information
    var permissionDetails: String {
        switch permissionStatus {
        case .granted:
            if grantedDirectories.isEmpty {
                return "No accessible directories found"
            } else {
                return grantedDirectories.map { $0.path }.joined(separator: "\n")
            }
        case .denied:
            return "Access to previously granted directories was revoked"
        case .restricted:
            return "System security policies prevent file access"
        case .needsUserAction:
            return "Click 'Grant Permission' to select directories for JSON file access"
        case .unknown:
            return "Permission status is being determined"
        }
    }

    /// Get a user-friendly permission status color
    var permissionStatusColor: String {
        switch permissionStatus {
        case .granted:
            return "green"
        case .denied, .restricted:
            return "red"
        case .needsUserAction:
            return "orange"
        case .unknown:
            return "gray"
        }
    }
    
    /// Revoke all granted permissions
    func revokeAllPermissions() {
        logger.info("Revoking all file access permissions")
        bookmarkManager.clearAllBookmarks()
        checkFileAccessPermission()
    }
    
    /// Add additional directory access
    func addDirectoryAccess() async -> Bool {
        return await requestFileAccessPermission()
    }
}
