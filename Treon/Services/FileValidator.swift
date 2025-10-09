//
//  FileValidator.swift
//  Treon
//
//  Created by AI Assistant on 2024-12-19.
//  Copyright © 2024 Treon. All rights reserved.
//

import Foundation
import os.log

/// Handles file validation and loading operations
class FileValidator {
    static let shared = FileValidator()
    
    private let logger = Logger(subsystem: "com.treon.app", category: "FileValidator")
    
    private init() {
        logger.info("Initializing FileValidator")
    }
    
    // MARK: - File Validation
    
    /// Validates and loads a file from the given URL
    func validateAndLoadFile(url: URL) async throws -> FileInfo {
        logger.info("Validating file: \(url.path)")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.error("File does not exist: \(url.path)")
            throw FileManagerError.fileNotFound(url.path)
        }
        
        // Check file extension
        guard url.pathExtension.lowercased() == "json" else {
            logger.error("Unsupported file type: \(url.pathExtension)")
            throw FileManagerError.unsupportedFileType(url.pathExtension)
        }
        
        // Check file size
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let fileSize = attributes[.size] as? Int64 else {
            logger.error("Could not determine file size")
            throw FileManagerError.unknownError("Could not determine file size")
        }
        
        // Check if file is too large (100MB limit)
        let maxSize: Int64 = 100 * 1024 * 1024 // 100MB
        if fileSize > maxSize {
            logger.error("File too large: \(fileSize) bytes")
            throw FileManagerError.fileTooLarge(fileSize, maxSize)
        }
        
        // Read file content
        let content: String
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            logger.error("Failed to read file content: \(error.localizedDescription)")
            throw FileManagerError.unknownError("Failed to read file content: \(error.localizedDescription)")
        }
        
        // Validate JSON
        let isValidJSON: Bool
        do {
            _ = try JSONSerialization.jsonObject(with: content.data(using: .utf8) ?? Data())
            isValidJSON = true
            logger.info("File contains valid JSON")
        } catch {
            isValidJSON = false
            logger.warning("File does not contain valid JSON: \(error.localizedDescription)")
        }
        
        // Create FileInfo
        let fileInfo = FileInfo(
            url: url,
            name: url.lastPathComponent,
            size: fileSize,
            modifiedDate: attributes[.modificationDate] as? Date ?? Date(),
            isValidJSON: isValidJSON,
            errorMessage: isValidJSON ? nil : "Invalid JSON content",
            content: content
        )
        
        logger.info("Successfully validated file: \(fileInfo.name)")
        return fileInfo
    }
    
    /// Validates JSON content without loading from file
    func validateJSONContent(_ content: String) -> Bool {
        do {
            _ = try JSONSerialization.jsonObject(with: content.data(using: .utf8) ?? Data())
            return true
        } catch {
            logger.warning("Invalid JSON content: \(error.localizedDescription)")
            return false
        }
    }
}
