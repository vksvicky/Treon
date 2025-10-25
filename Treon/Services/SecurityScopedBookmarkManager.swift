//
//  SecurityScopedBookmarkManager.swift
//  Treon
//
//  Created by Vivek on 2025-10-22.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import AppKit
import OSLog

/// Manages security-scoped bookmarks for persistent file access
@MainActor
class SecurityScopedBookmarkManager {
    static let shared = SecurityScopedBookmarkManager()
    
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "SecurityScopedBookmarkManager")
    private let bookmarksKey = "security_scoped_bookmarks"
    
    private init() {
        logger.info("Initializing SecurityScopedBookmarkManager")
    }
    
    // MARK: - Bookmark Management
    
    /// Creates a regular bookmark for the given URL (not security-scoped)
    /// - Parameter url: The URL to create a bookmark for
    /// - Returns: The bookmark data if successful, nil otherwise
    func createBookmark(for url: URL) -> Data? {
        do {
            // Create a security-scoped bookmark that will persist across app launches
            let bookmarkData = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            logger.info("Created security-scoped bookmark for: \(url.lastPathComponent)")
            return bookmarkData
        } catch {
            logger.error("Failed to create bookmark for \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Resolves a regular bookmark to a URL
    /// - Parameter bookmarkData: The bookmark data to resolve
    /// - Returns: The resolved URL if successful, nil otherwise
    func resolveBookmark(_ bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                logger.warning("🚀 Bookmark is stale for: \(url.lastPathComponent), will need to get permission again")
                return nil
            }
            
            logger.info("Resolved security-scoped bookmark to: \(url.lastPathComponent)")
            return url
        } catch {
            logger.error("Failed to resolve bookmark: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Starts accessing a security-scoped resource
    /// - Parameter url: The URL to start accessing
    /// - Returns: True if access was granted, false otherwise
    func startAccessingSecurityScopedResource(_ url: URL) -> Bool {
        let success = url.startAccessingSecurityScopedResource()
        if success {
            logger.info("Started accessing security-scoped resource: \(url.lastPathComponent)")
        } else {
            logger.warning("Failed to start accessing security-scoped resource: \(url.lastPathComponent)")
        }
        return success
    }
    
    /// Stops accessing a security-scoped resource
    /// - Parameter url: The URL to stop accessing
    func stopAccessingSecurityScopedResource(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
        logger.info("Stopped accessing security-scoped resource: \(url.lastPathComponent)")
    }
    
    // MARK: - Persistent Storage
    
    /// Saves a bookmark for a URL
    /// - Parameters:
    ///   - bookmarkData: The bookmark data to save
    ///   - url: The URL the bookmark is for
    func saveBookmark(_ bookmarkData: Data, for url: URL) {
        var bookmarks = loadAllBookmarks()
        bookmarks[url.path] = bookmarkData
        saveAllBookmarks(bookmarks)
        logger.info("Saved bookmark for: \(url.lastPathComponent)")
    }
    
    /// Loads a bookmark for a URL
    /// - Parameter url: The URL to load bookmark for
    /// - Returns: The bookmark data if found, nil otherwise
    func loadBookmark(for url: URL) -> Data? {
        let bookmarks = loadAllBookmarks()
        return bookmarks[url.path]
    }
    
    /// Removes a bookmark for a URL
    /// - Parameter url: The URL to remove bookmark for
    func removeBookmark(for url: URL) {
        var bookmarks = loadAllBookmarks()
        bookmarks.removeValue(forKey: url.path)
        saveAllBookmarks(bookmarks)
        logger.info("Removed bookmark for: \(url.lastPathComponent)")
    }
    
    /// Loads all bookmarks from UserDefaults
    /// - Returns: Dictionary of file paths to bookmark data
    func loadAllBookmarks() -> [String: Data] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey),
              let bookmarks = try? JSONDecoder().decode([String: Data].self, from: data) else {
            return [:]
        }
        return bookmarks
    }
    
    /// Saves all bookmarks to UserDefaults
    /// - Parameter bookmarks: Dictionary of file paths to bookmark data
    func saveAllBookmarks(_ bookmarks: [String: Data]) {
        do {
            let data = try JSONEncoder().encode(bookmarks)
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        } catch {
            logger.error("Failed to save bookmarks: \(error.localizedDescription)")
        }
    }
    
    /// Clears all saved bookmarks
    func clearAllBookmarks() {
        UserDefaults.standard.removeObject(forKey: bookmarksKey)
        logger.info("Cleared all bookmarks")
    }
    
    // MARK: - Cleanup
    
    /// Cleans up stale bookmarks (files that no longer exist)
    func cleanupStaleBookmarks() {
        let bookmarks = loadAllBookmarks()
        var updatedBookmarks = bookmarks
        
        for (path, bookmarkData) in bookmarks {
            if let url = resolveBookmark(bookmarkData) {
                // Check if file still exists
                if !FileManager.default.fileExists(atPath: url.path) {
                    logger.info("Removing stale bookmark for non-existent file: \(path)")
                    updatedBookmarks.removeValue(forKey: path)
                }
            } else {
                logger.info("Removing invalid bookmark: \(path)")
                updatedBookmarks.removeValue(forKey: path)
            }
        }
        
        if updatedBookmarks.count != bookmarks.count {
            saveAllBookmarks(updatedBookmarks)
            logger.info("Cleaned up \(bookmarks.count - updatedBookmarks.count) stale bookmarks")
        }
    }
}
