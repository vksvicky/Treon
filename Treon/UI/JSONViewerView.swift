//
//  JSONViewerView.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import SwiftUI
import AppKit
import OSLog

struct JSONViewerView: View {
    @StateObject private var fileManager = TreonFileManager.shared
    @StateObject private var settings = UserSettingsManager.shared
    @State private var jsonText: String = ""
    @State private var rootNode: JSONNode? = nil
    @State private var showingError = false
    @State private var errorMessage = ""
    @StateObject private var expansion = TreeExpansionState()
    
    let fileInfo: FileInfo?
    private let logger = Loggers.ui
    
    init(fileInfo: FileInfo? = nil) {
        self.fileInfo = fileInfo
    }

    // Xcode-style navigator state - now using settings manager
    @State private var isDragging = false
    private let minNavigatorWidth: CGFloat = 200
    private let maxNavigatorWidth: CGFloat = 600

    var body: some View {
        HStack(spacing: 0) {
            // Left pane - Tree Navigator (Xcode-style)
            if !settings.isNavigatorCollapsed {
                treeNavigator
                    .frame(minWidth: 200, idealWidth: 400, maxWidth: maxNavigatorWidth)
                    .frame(width: settings.navigatorWidth)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.25), value: settings.isNavigatorCollapsed)
            } else {
                // Collapsed state indicator (Xcode-style)
                collapsedNavigatorIndicator
                    .frame(width: 20)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.25), value: settings.isNavigatorCollapsed)
            }

            // Resize handle (Xcode-style)
            if !settings.isNavigatorCollapsed && !settings.isNavigatorPinned {
                resizeHandle
            }

            // Right pane - JSON Text Editor
            jsonEditor
                .frame(minWidth: 400)
        }
        .onAppear {
            loadCurrentFile()
            setupWindowFrameTracking()
        }
        .onChange(of: fileInfo?.url) {
            loadCurrentFile()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleNavigator"))) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                settings.isNavigatorCollapsed.toggle()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var treeNavigator: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (Xcode-style)
            HStack {
                Button(action: {
                    if !settings.isNavigatorPinned {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            settings.isNavigatorCollapsed.toggle()
                        }
                    }
                }) {
                    Image(systemName: settings.isNavigatorCollapsed ? "chevron.right" : "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(settings.isNavigatorPinned ? .secondary.opacity(0.5) : .secondary)
                }
                .buttonStyle(.borderless)
                .frame(width: 16, height: 16)
                .disabled(settings.isNavigatorPinned)

                Text("Navigator")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 8) {
                    // Pin button (Xcode-style)
                    Button(action: {
                        settings.isNavigatorPinned.toggle()
                    }) {
                        Image(systemName: settings.isNavigatorPinned ? "lock.fill" : "lock.open.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(settings.isNavigatorPinned ? .blue : .secondary)
                    }
                    .buttonStyle(.borderless)
                    .help(settings.isNavigatorPinned ? "Unlock Navigator" : "Lock Navigator")

                    Button("Expand All") {
                        if let rootNode { expansion.expandAll(root: rootNode) }
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)

                    Button("Collapse All") {
                        expansion.resetAll()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Tree view
            if let rootNode = rootNode {
                ListTreeView(root: rootNode, expansion: expansion)
            } else {
                VStack {
                    Spacer()
                    Text("No JSON content to display")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Spacer()
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    // Xcode-style collapsed navigator indicator
    private var collapsedNavigatorIndicator: some View {
        VStack {
            Button(action: {
                if !settings.isNavigatorPinned {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        settings.isNavigatorCollapsed = false
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(settings.isNavigatorPinned ? .secondary.opacity(0.5) : .secondary)
            }
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
        }
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1),
            alignment: .trailing
        )
    }

    // Xcode-style resize handle
    private var resizeHandle: some View {
        Rectangle()
            .fill(Color(NSColor.separatorColor))
            .frame(width: 1)
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 8)
                    .contentShape(Rectangle())
                    .onHover { isHovering in
                        NSCursor.resizeLeftRight.set()
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                    NSCursor.resizeLeftRight.push()
                                }

                                let newWidth = settings.navigatorWidth + value.translation.width
                                settings.navigatorWidth = max(minNavigatorWidth, min(maxNavigatorWidth, newWidth))
                            }
                            .onEnded { _ in
                                isDragging = false
                                NSCursor.pop()
                            }
                    )
            )
    }

    private var jsonEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("JSON Editor")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                HStack(spacing: 8) {
                    Button("Close") {
                        closeFile()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)

                    Button("Format") {
                        formatJSON()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)

                    Button("Minify") {
                        minifyJSON()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)

                    Button("Copy") {
                        copyToClipboard()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Text editor
            ScrollView {
                TextEditor(text: $jsonText)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
            }
            .background(Color(NSColor.textBackgroundColor))
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func loadCurrentFile() {
        let displayStartTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 DISPLAY START: Beginning file display for \(fileInfo?.name ?? "unknown")")
        
        guard let fileInfo = fileInfo else {
            jsonText = ""
            rootNode = nil
            expansion.resetAll()
            return
        }

        // Load file content if not already loaded
        if let content = fileInfo.content {
            let contentLoadTime = CFAbsoluteTimeGetCurrent()
            jsonText = content
            let contentLoadDuration = CFAbsoluteTimeGetCurrent() - contentLoadTime
            logger.debug("📊 DISPLAY STEP 1: Content loading (from FileInfo): \(String(format: "%.3f", contentLoadDuration))s")
        } else if let url = fileInfo.url {
            Task {
                do {
                    let networkLoadStart = CFAbsoluteTimeGetCurrent()
                    let content = try await fileManager.getFileContent(url: url)
                    let networkLoadTime = CFAbsoluteTimeGetCurrent() - networkLoadStart
                    logger.debug("📊 DISPLAY STEP 1: Network content loading: \(String(format: "%.3f", networkLoadTime))s")
                    
                    await MainActor.run {
                        let contentSetStart = CFAbsoluteTimeGetCurrent()
                        jsonText = content
                        let contentSetTime = CFAbsoluteTimeGetCurrent() - contentSetStart
                        logger.debug("📊 DISPLAY STEP 2: Content setting: \(String(format: "%.3f", contentSetTime))s")
                        parseJSONContent()
                        
                        let totalDisplayTime = CFAbsoluteTimeGetCurrent() - displayStartTime
                        logger.info("📊 DISPLAY TOTAL: \(String(format: "%.3f", totalDisplayTime))s for \(fileInfo.name)")
                    }
                } catch {
                    await MainActor.run {
                        showError("Failed to load file content: \(error.localizedDescription)")
                    }
                }
            }
            return
        } else {
            jsonText = ""
        }

        parseJSONContent()
        
        let totalDisplayTime = CFAbsoluteTimeGetCurrent() - displayStartTime
        logger.info("📊 DISPLAY TOTAL: \(String(format: "%.3f", totalDisplayTime))s for \(fileInfo.name)")
    }

    private func parseJSONContent() {
        guard let fileInfo = fileInfo else {
            rootNode = nil
            return
        }

        if fileInfo.isValidJSON {
            processValidJSON(fileInfo: fileInfo)
        } else {
            handleInvalidJSON(fileInfo: fileInfo)
        }
    }
    
    private func processValidJSON(fileInfo: FileInfo) {
        let currentText = jsonText
        let parseStartTime = CFAbsoluteTimeGetCurrent()
        logger.info("📊 HYBRID PARSING START: Beginning hybrid JSON processing for \(fileInfo.name)")
        
        Task {
            do {
                let data = try await JSONViewerHelpers.convertTextToData(currentText)
                let built = try await JSONViewerHelpers.processJSONData(data, fileInfo: fileInfo)
                await updateUIWithResult(built, currentText: currentText, parseStartTime: parseStartTime, fileInfo: fileInfo)
            } catch {
                await JSONViewerHelpers.handleParsingError(error, showError: showError, expansion: expansion)
            }
        }
    }
    
    private func updateUIWithResult(_ built: JSONNode, currentText: String, parseStartTime: CFAbsoluteTime, fileInfo: FileInfo) async {
        await MainActor.run {
            let uiUpdateStart = CFAbsoluteTimeGetCurrent()
            logger.debug("📊 HYBRID PARSING STEP 3: Starting UI update on main thread")
            
            if currentText == self.jsonText {
                updateRootNode(built, dataSize: currentText.utf8.count)
                
                let uiUpdateTime = CFAbsoluteTimeGetCurrent() - uiUpdateStart
                let totalParseTime = CFAbsoluteTimeGetCurrent() - parseStartTime
                logger.debug("📊 HYBRID PARSING STEP 3B: UI update complete: \(String(format: "%.3f", uiUpdateTime))s")
                logger.info("📊 HYBRID PARSING TOTAL: \(String(format: "%.3f", totalParseTime))s for \(fileInfo.name)")
            }
        }
    }
    
    private func updateRootNode(_ built: JSONNode, dataSize: Int) {
        let rootNodeSetStart = CFAbsoluteTimeGetCurrent()
        
        if dataSize > 100 * 1024 * 1024 { // 100MB threshold
            logger.info("📊 HYBRID PARSING: Using conservative UI update for very large file (\(dataSize) bytes)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.rootNode = built
                self.expansion.resetAll()
            }
        } else {
            self.rootNode = built
            self.expansion.resetAll()
        }
        
        let rootNodeSetTime = CFAbsoluteTimeGetCurrent() - rootNodeSetStart
        logger.debug("📊 HYBRID PARSING STEP 3A: rootNode assignment: \(String(format: "%.3f", rootNodeSetTime))s")
    }
    
    private func handleInvalidJSON(fileInfo: FileInfo) {
        rootNode = nil
        JSONViewerHelpers.handleInvalidJSON(fileInfo: fileInfo, showError: showError, expansion: expansion)
    }
    
    // MARK: - Window Frame Tracking
    private func setupWindowFrameTracking() {
        JSONViewerHelpers.setupWindowFrameTracking(settings: settings)
    }
    
    
    private func countNodes(_ node: JSONNode) -> Int {
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
        
        // If we hit the limit, return an estimated count
        if count >= maxCount {
            return maxCount // Return the limit as an estimate
        }
        
        return count
    }

    private func formatJSON() {
        do {
            let data = Data(jsonText.utf8)
            let pretty = try JSONFormatter().prettyPrinted(from: data)
            jsonText = String(decoding: pretty, as: UTF8.self)

            // Rebuild tree
            rootNode = try JSONTreeBuilder.build(from: pretty)
        } catch {
            showError("Failed to format JSON: \(error.localizedDescription)")
        }
    }

    private func minifyJSON() {
        do {
            let data = Data(jsonText.utf8)
            let minified = try JSONFormatter().minified(from: data)
            jsonText = String(decoding: minified, as: UTF8.self)

            // Rebuild tree
            rootNode = try JSONTreeBuilder.build(from: minified)
        } catch {
            showError("Failed to minify JSON: \(error.localizedDescription)")
        }
    }

    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(jsonText, forType: .string)
    }

    private func closeFile() {
        // Close the current tab if we have a fileInfo
        if let fileInfo = fileInfo {
            // Find the tab for this file and close it
            if let tab = TabManager.shared.tabs.first(where: { $0.fileInfo.url == fileInfo.url }) {
                TabManager.shared.closeTab(tab.id)
            }
        }
        jsonText = ""
        rootNode = nil
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - Tree View Components
// Using existing ListTreeView and NodeRow from TwoPaneRootView.swift

#Preview {
    JSONViewerView()
        .frame(width: 800, height: 600)
}
