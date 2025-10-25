//
//  JSONViewerHelpers.swift
//  Treon
//
//  Created by Vivek on 2025-10-24.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import SwiftUI
import OSLog

/// Helper functions for JSON viewer functionality
struct JSONViewerHelpers {
    
    // MARK: - JSON Processing Helpers
    
    static func convertTextToData(_ text: String) async throws -> Data {
        let dataConversionStart = CFAbsoluteTimeGetCurrent()
        let data = Data(text.utf8)
        let dataConversionTime = CFAbsoluteTimeGetCurrent() - dataConversionStart
        let logger = Loggers.ui
        logger.debug("📊 HYBRID PARSING STEP 1: Data conversion: \(String(format: "%.3f", dataConversionTime))s (size: \(data.count) bytes)")
        return data
    }
    
    static func processJSONData(_ data: Data, fileInfo: FileInfo) async throws -> JSONNode {
        let logger = Loggers.ui
        logger.info("📊 HYBRID PARSING: File size: \(String(format: "%.2f", Double(data.count) / 1024 / 1024)) MB")
        logger.info("📊 HYBRID PARSING: Using Rust backend for all processing")
        
        let treeBuildStart = CFAbsoluteTimeGetCurrent()
        let built = try await HybridJSONProcessor.processData(data)
        let treeBuildTime = CFAbsoluteTimeGetCurrent() - treeBuildStart
        
        let nodeCount = countNodes(built)
        logger.debug("📊 HYBRID PARSING STEP 2: Tree building: \(String(format: "%.3f", treeBuildTime))s (nodes: \(nodeCount))")
        return built
    }
    
    static func updateUIWithResult(_ built: JSONNode, currentText: String, parseStartTime: CFAbsoluteTime, fileInfo: FileInfo, settings: UserSettingsManager, expansion: TreeExpansionState) async {
        await MainActor.run {
            let uiUpdateStart = CFAbsoluteTimeGetCurrent()
            let logger = Loggers.ui
            logger.debug("📊 HYBRID PARSING STEP 3: Starting UI update on main thread")
            
            if currentText == currentText { // This will be updated by the caller
                updateRootNode(built, dataSize: currentText.utf8.count, settings: settings, expansion: expansion)
                
                let uiUpdateTime = CFAbsoluteTimeGetCurrent() - uiUpdateStart
                let totalParseTime = CFAbsoluteTimeGetCurrent() - parseStartTime
                logger.debug("📊 HYBRID PARSING STEP 3B: UI update complete: \(String(format: "%.3f", uiUpdateTime))s")
                logger.info("📊 HYBRID PARSING TOTAL: \(String(format: "%.3f", totalParseTime))s for \(fileInfo.name)")
            }
        }
    }
    
    static func updateRootNode(_ built: JSONNode, dataSize: Int, settings: UserSettingsManager, expansion: TreeExpansionState) {
        let rootNodeSetStart = CFAbsoluteTimeGetCurrent()
        let logger = Loggers.ui
        
        if dataSize > 100 * 1024 * 1024 { // 100MB threshold
            logger.info("📊 HYBRID PARSING: Using conservative UI update for very large file (\(dataSize) bytes)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // This will be handled by the caller
            }
        } else {
            // This will be handled by the caller
        }
        
        let rootNodeSetTime = CFAbsoluteTimeGetCurrent() - rootNodeSetStart
        logger.debug("📊 HYBRID PARSING STEP 3A: rootNode assignment: \(String(format: "%.3f", rootNodeSetTime))s")
    }
    
    static func handleParsingError(_ error: Error, showError: @escaping (String) -> Void, expansion: TreeExpansionState) async {
        await MainActor.run {
            if let nsError = error as NSError?, nsError.code == 408 {
                showError("File too large to parse completely. Tree view will show limited content. Use the text view for full content.")
                expansion.resetAll()
            } else {
                showError("Failed to parse JSON: \(error.localizedDescription)")
                expansion.resetAll()
            }
        }
    }
    
    static func handleInvalidJSON(fileInfo: FileInfo, showError: @escaping (String) -> Void, expansion: TreeExpansionState) {
        expansion.resetAll()
        if let errorMsg = fileInfo.errorMessage {
            showError(errorMsg)
        }
    }
    
    // MARK: - Node Counting
    
    static func countNodes(_ node: JSONNode) -> Int {
        // Efficient counting with early termination for very large trees
        var count = 1
        var stack = node.children
        let maxCount = 1000000 // Increased limit for larger files
        
        while let child = stack.popLast(), count < maxCount {
            count += 1
            // Only add children if we haven't hit the limit yet
            if count < maxCount {
                stack.append(contentsOf: child.children)
            }
        }
        
        return count
    }
    
    // MARK: - Window Frame Tracking
    
    static func setupWindowFrameTracking(settings: UserSettingsManager) {
        // Set up window frame tracking to save dimensions
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // Set initial frame from settings
                window.setFrame(settings.windowFrame, display: true)
                
                // Observe window frame changes
                NotificationCenter.default.addObserver(
                    forName: NSWindow.didResizeNotification,
                    object: window,
                    queue: .main
                ) { _ in
                    Task { @MainActor in
                        settings.windowFrame = window.frame
                    }
                }
                
                NotificationCenter.default.addObserver(
                    forName: NSWindow.didMoveNotification,
                    object: window,
                    queue: .main
                ) { _ in
                    Task { @MainActor in
                        settings.windowFrame = window.frame
                    }
                }
            }
        }
    }
}
