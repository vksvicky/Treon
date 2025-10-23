import Foundation
import OSLog

/// Manages recent files functionality
class RecentFilesManager {
    static let shared = RecentFilesManager()
    
    private let logger = Loggers.fileManager
    private let recentFilesKey = UserDefaultsKeys.recentFiles
    private let maxRecentFiles = FileConstants.maxRecentFiles
    
    private init() {}
    
    // MARK: - Recent Files Management
    
    func addToRecentFiles(fileInfo: FileInfo) {
        // Only add to recent files if there's a valid URL (not content-based files) and valid JSON
        guard let url = fileInfo.url, fileInfo.isValidJSON else { return }

        // Create a bookmark for this file since it was opened through the file dialog
        // (which means the user has already granted permission)
        let bookmarkData = SecurityScopedBookmarkManager.shared.createBookmark(for: url)
        if bookmarkData != nil {
            logger.info("🚀 Created bookmark for recent file: \(url.lastPathComponent)")
        } else {
            logger.warning("🚀 Failed to create bookmark for recent file: \(url.lastPathComponent)")
        }
        
        let recentFile = RecentFile(
            url: url,
            name: fileInfo.name,
            lastOpened: Date(),
            size: fileInfo.size,
            isValidJSON: fileInfo.isValidJSON,
            bookmarkData: bookmarkData
        )

        // Remove existing entry if it exists
        var recentFiles = loadRecentFiles()
        recentFiles.removeAll { $0.url == url }

        // Add to beginning
        recentFiles.insert(recentFile, at: 0)

        // Keep only maxRecentFiles
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }

        saveRecentFiles(recentFiles)
    }
    
    func loadRecentFiles() -> [RecentFile] {
        guard let data = UserDefaults.standard.data(forKey: recentFilesKey) else { return [] }

        do {
            let decoder = JSONDecoder()
            let files = try decoder.decode([RecentFile].self, from: data)
            logger.info("🚀 Loaded \(files.count) recent files")
            return files
        } catch {
            logger.error("Failed to load recent files: \(error)")
            return []
        }
    }
    
    func saveRecentFiles(_ files: [RecentFile]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(files)
            UserDefaults.standard.set(data, forKey: recentFilesKey)
        } catch {
            logger.error("Failed to save recent files: \(error)")
        }
    }
    
    func clearAllRecentFiles() {
        saveRecentFiles([])
        logger.info("🚀 Cleared all recent files")
    }
    
    func removeRecentFile(_ recentFile: RecentFile) {
        var files = loadRecentFiles()
        files.removeAll { $0.id == recentFile.id }
        saveRecentFiles(files)
        logger.info("Removed recent file: \(recentFile.name)")
    }
    
    func updateRecentFileAccess(_ recentFile: RecentFile) {
        var files = loadRecentFiles()
        if let index = files.firstIndex(where: { $0.id == recentFile.id }) {
            let updatedFile = RecentFile(
                url: recentFile.url,
                name: recentFile.name,
                lastOpened: Date(),
                size: recentFile.size,
                isValidJSON: recentFile.isValidJSON,
                bookmarkData: recentFile.bookmarkData
            )
            files[index] = updatedFile
            saveRecentFiles(files)
        }
    }
    
    func updateRecentFileWithBookmark(url: URL, bookmarkData: Data) {
        var files = loadRecentFiles()
        if let index = files.firstIndex(where: { $0.url == url }) {
            let updatedFile = RecentFile(
                url: files[index].url,
                name: files[index].name,
                lastOpened: Date(),
                size: files[index].size,
                isValidJSON: files[index].isValidJSON,
                bookmarkData: bookmarkData
            )
            files[index] = updatedFile
            saveRecentFiles(files)
            logger.info("Updated recent file with bookmark: \(url.lastPathComponent)")
        }
    }
}
