import Foundation
import AppKit
import OSLog
import Combine
import UniformTypeIdentifiers

/// Centralized permission management for file access
class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "PermissionManager")
    
    @Published var hasFileAccessPermission: Bool = false
    
    private init() {
        checkFileAccessPermission()
    }
    
    /// Check if the app has file access permission
    func checkFileAccessPermission() {
        // Check if we can access the Downloads folder (common location for files)
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let testFile = downloadsURL.appendingPathComponent(".treon_permission_test")
        
        do {
            // Try to create a test file
            try "test".write(to: testFile, atomically: true, encoding: .utf8)
            // If successful, clean up and set permission to true
            try FileManager.default.removeItem(at: testFile)
            hasFileAccessPermission = true
            logger.info("File access permission: GRANTED")
        } catch {
            hasFileAccessPermission = false
            logger.warning("File access permission: DENIED - \(error.localizedDescription)")
        }
    }
    
    /// Request file access permission by opening a file dialog
    func requestFileAccessPermission() async -> Bool {
        logger.info("Requesting file access permission")
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.json]
                panel.title = "Grant File Access Permission"
                panel.message = "Please select any JSON file to grant Treon permission to access files on your system."
                
                if panel.runModal() == .OK {
                    self.logger.info("User granted file access permission")
                    self.hasFileAccessPermission = true
                    continuation.resume(returning: true)
                } else {
                    self.logger.info("User denied file access permission")
                    continuation.resume(returning: false)
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
        if hasFileAccessPermission {
            return "File access permission is granted"
        } else {
            return "File access permission is required"
        }
    }
    
    /// Get a user-friendly permission status color
    var permissionStatusColor: String {
        if hasFileAccessPermission {
            return "green"
        } else {
            return "red"
        }
    }
}
