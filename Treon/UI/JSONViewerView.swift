import SwiftUI
import AppKit

struct JSONViewerView: View {
    @StateObject private var fileManager = TreonFileManager.shared
    @State private var jsonText: String = ""
    @State private var rootNode: JSONNode? = nil
    @State private var showingError = false
    @State private var errorMessage = ""
    @StateObject private var expansion = TreeExpansionState()
    
    // Xcode-style navigator state
    @State private var navigatorWidth: CGFloat = 400
    @State private var isNavigatorCollapsed = false
    @State private var isDragging = false
    @State private var isNavigatorPinned = false
    private let minNavigatorWidth: CGFloat = 200
    private let maxNavigatorWidth: CGFloat = 600
    
    var body: some View {
        HStack(spacing: 0) {
            // Left pane - Tree Navigator (Xcode-style)
            if !isNavigatorCollapsed {
                treeNavigator
                    .frame(minWidth: 200, idealWidth: 400, maxWidth: maxNavigatorWidth)
                    .frame(width: navigatorWidth)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.25), value: isNavigatorCollapsed)
            } else {
                // Collapsed state indicator (Xcode-style)
                collapsedNavigatorIndicator
                    .frame(width: 20)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.25), value: isNavigatorCollapsed)
            }
            
            // Resize handle (Xcode-style)
            if !isNavigatorCollapsed && !isNavigatorPinned {
                resizeHandle
            }
            
            // Right pane - JSON Text Editor
            jsonEditor
                .frame(minWidth: 400)
        }
        .onAppear {
            loadCurrentFile()
        }
        .onChange(of: fileManager.currentFile?.url) {
            loadCurrentFile()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ToggleNavigator"))) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                isNavigatorCollapsed.toggle()
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
                    if !isNavigatorPinned {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isNavigatorCollapsed.toggle()
                        }
                    }
                }) {
                    Image(systemName: isNavigatorCollapsed ? "chevron.right" : "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isNavigatorPinned ? .secondary.opacity(0.5) : .secondary)
                }
                .buttonStyle(.borderless)
                .frame(width: 16, height: 16)
                .disabled(isNavigatorPinned)
                
                Text("Navigator")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Pin button (Xcode-style)
                    Button(action: { 
                        isNavigatorPinned.toggle()
                    }) {
                        Image(systemName: isNavigatorPinned ? "pin.fill" : "pin")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isNavigatorPinned ? .blue : .secondary)
                    }
                    .buttonStyle(.borderless)
                    .help(isNavigatorPinned ? "Unpin Navigator" : "Pin Navigator")
                    
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
                if !isNavigatorPinned {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isNavigatorCollapsed = false
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isNavigatorPinned ? .secondary.opacity(0.5) : .secondary)
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
                                
                                let newWidth = navigatorWidth + value.translation.width
                                navigatorWidth = max(minNavigatorWidth, min(maxNavigatorWidth, newWidth))
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
        guard let fileInfo = fileManager.currentFile else {
            jsonText = ""
            rootNode = nil
            return
        }
        
        // Load file content if not already loaded
        if let content = fileInfo.content {
            jsonText = content
        } else if let url = fileInfo.url {
            Task {
                do {
                    let content = try await fileManager.getFileContent(url: url)
                    await MainActor.run {
                        jsonText = content
                        parseJSONContent()
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
    }
    
    private func parseJSONContent() {
        guard let fileInfo = fileManager.currentFile else {
            rootNode = nil
            return
        }
        
        // Parse JSON to build tree on a background queue to avoid blocking UI
        if fileInfo.isValidJSON {
            let currentText = jsonText
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = Data(currentText.utf8)
                    let built = try JSONTreeBuilder.build(from: data)
                    DispatchQueue.main.async {
                        // Only apply if text hasn't changed in the meantime
                        if currentText == self.jsonText {
                            self.rootNode = built
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showError("Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            rootNode = nil
            if let errorMsg = fileInfo.errorMessage {
                showError(errorMsg)
            }
        }
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
        fileManager.currentFile = nil
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
