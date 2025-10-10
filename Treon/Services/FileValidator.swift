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
        let startTime = CFAbsoluteTimeGetCurrent()
        logger.info("Validating file: \(url.path)")
        
        // Perform basic file checks
        let (fileSize, attributes) = try await performBasicFileChecks(url: url)
        
        // Read file content
        let content = try await readFileContent(url: url, fileSize: fileSize)
        
        // Validate JSON
        let isValidJSON = validateJSONContentWithLogging(content)
        
        // Create and return FileInfo
        let fileInfo = createFileInfo(url: url, fileSize: fileSize, attributes: attributes, 
                                    content: content, isValidJSON: isValidJSON)
        
        let totalValidationTime = CFAbsoluteTimeGetCurrent() - startTime
        logger.info("📊 VALIDATION TOTAL: \(String(format: "%.3f", totalValidationTime))s for \(fileInfo.name)")
        
        if isValidJSON {
            logger.info("Successfully validated file: \(fileInfo.name)")
        } else {
            logger.info("File validation completed (invalid JSON): \(fileInfo.name)")
        }
        return fileInfo
    }
    
    /// Performs basic file existence, extension, and size checks
    private func performBasicFileChecks(url: URL) async throws -> (Int64, [FileAttributeKey: Any]) {
        // Check if file exists
        let fileCheckStart = CFAbsoluteTimeGetCurrent()
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.error("File does not exist: \(url.path)")
            throw FileManagerError.fileNotFound(url.path)
        }
        let fileCheckTime = CFAbsoluteTimeGetCurrent() - fileCheckStart
        logger.info("📊 VALIDATION STEP 1: File existence check: \(String(format: "%.3f", fileCheckTime))s")
        
        // Check file extension
        let extensionCheckStart = CFAbsoluteTimeGetCurrent()
        guard url.pathExtension.lowercased() == "json" else {
            logger.error("Unsupported file type: \(url.pathExtension)")
            throw FileManagerError.unsupportedFileType(url.pathExtension)
        }
        let extensionCheckTime = CFAbsoluteTimeGetCurrent() - extensionCheckStart
        logger.info("📊 VALIDATION STEP 2: Extension check: \(String(format: "%.3f", extensionCheckTime))s")
        
        // Check file size
        let sizeCheckStart = CFAbsoluteTimeGetCurrent()
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let fileSize = attributes[.size] as? Int64 else {
            logger.error("Could not determine file size")
            throw FileManagerError.unknownError("Could not determine file size")
        }
        let sizeCheckTime = CFAbsoluteTimeGetCurrent() - sizeCheckStart
        logger.info("📊 VALIDATION STEP 3: Size check: \(String(format: "%.3f", sizeCheckTime))s (size: \(fileSize) bytes)")
        
        // Check if file is too large
        let maxSize: Int64 = FileConstants.maxFileSize
        if fileSize > maxSize {
            logger.error("File too large: \(fileSize) bytes")
            throw FileManagerError.fileTooLarge(fileSize, maxSize)
        }
        
        return (fileSize, attributes)
    }
    
    /// Reads file content with optimized approach for large files
    private func readFileContent(url: URL, fileSize: Int64) async throws -> String {
        let readStart = CFAbsoluteTimeGetCurrent()
        let content: String
        do {
            if fileSize > 10 * 1024 * 1024 { // 10MB threshold
                // Use memory-mapped file reading for large files
                logger.info("Using memory-mapped file reading for large file (\(fileSize) bytes)")
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                content = String(data: data, encoding: .utf8) ?? ""
            } else {
                // Use standard reading for smaller files
                content = try String(contentsOf: url, encoding: .utf8)
            }
        } catch {
            logger.error("Failed to read file content: \(error.localizedDescription)")
            throw FileManagerError.unknownError("Failed to read file content: \(error.localizedDescription)")
        }
        let readTime = CFAbsoluteTimeGetCurrent() - readStart
        logger.info("📊 VALIDATION STEP 4: File reading: \(String(format: "%.3f", readTime))s (content size: \(content.count) chars)")
        return content
    }
    
    /// Validates JSON content and returns validation result with logging
    private func validateJSONContentWithLogging(_ content: String) -> Bool {
        let jsonValidationStart = CFAbsoluteTimeGetCurrent()
        let isValidJSON: Bool
        do {
            _ = try JSONSerialization.jsonObject(with: content.data(using: .utf8) ?? Data())
            isValidJSON = true
            logger.info("File contains valid JSON")
        } catch {
            isValidJSON = false
            logger.warning("File does not contain valid JSON: \(error.localizedDescription)")
        }
        let jsonValidationTime = CFAbsoluteTimeGetCurrent() - jsonValidationStart
        logger.info("📊 VALIDATION STEP 5: JSON validation: \(String(format: "%.3f", jsonValidationTime))s (valid: \(isValidJSON))")
        return isValidJSON
    }
    
    /// Creates FileInfo object from validation results
    private func createFileInfo(url: URL, fileSize: Int64, attributes: [FileAttributeKey: Any], 
                              content: String, isValidJSON: Bool) -> FileInfo {
        return FileInfo(
            url: url,
            name: url.lastPathComponent,
            size: fileSize,
            modifiedDate: attributes[.modificationDate] as? Date ?? Date(),
            isValidJSON: isValidJSON,
            errorMessage: isValidJSON ? nil : "Invalid JSON content",
            content: content
        )
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
