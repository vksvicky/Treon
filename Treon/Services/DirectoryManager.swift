//
//  DirectoryManager.swift
//  Treon
//
//  Created by Vivek on 2024-10-19.
//  Copyright © 2024 Treon. All rights reserved.
//

import Foundation
import os.log

/// Manages directory memory functionality for file dialogs
@MainActor
class DirectoryManager {
    static let shared = DirectoryManager()
    
    private let logger = Logger(subsystem: "com.treon.app", category: "DirectoryManager")
    
    private init() {
        logger.info("Initializing DirectoryManager")
    }
    
    // MARK: - Directory Memory
    
    /// Gets the last opened directory from UserDefaults
    /// Falls back to Documents directory if no valid directory is stored
    func getLastOpenedDirectory() -> URL {
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.lastOpenedDirectory),
           let url = URL(dataRepresentation: data, relativeTo: nil) {
            // Verify the directory still exists
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                logger.info("Using last opened directory: \(url.path)")
                return url
            } else {
                logger.info("Last opened directory no longer exists, falling back to Documents")
                // Clear the invalid directory
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastOpenedDirectory)
            }
        }
        
        // Fall back to Documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
        logger.info("Using fallback directory: \(documentsURL.path)")
        return documentsURL
    }
    
    /// Saves the directory of the given file URL to UserDefaults
    func saveLastOpenedDirectory(url: URL) {
        let directoryURL = url.deletingLastPathComponent()
        
        let data = directoryURL.dataRepresentation
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.lastOpenedDirectory)
        logger.info("Saved last opened directory: \(directoryURL.path)")
    }
    
    /// Clears the stored directory memory
    func clearLastOpenedDirectory() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastOpenedDirectory)
        logger.info("Cleared last opened directory")
    }
}
