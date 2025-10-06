import SwiftUI
import AppKit

struct JSONViewerView: View {
    @StateObject private var fileManager = TreonFileManager.shared
    @State private var jsonText: String = ""
    @State private var rootNode: JSONNode? = nil
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        HSplitView {
            // Left pane - Tree Navigator
            treeNavigator
                .frame(minWidth: 200, maxWidth: 400)
            
            // Right pane - JSON Text Editor
            jsonEditor
                .frame(minWidth: 400)
        }
        .onAppear {
            loadCurrentFile()
        }
        .onChange(of: fileManager.currentFile?.url) { _ in
            loadCurrentFile()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var treeNavigator: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Navigator")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("Expand All") {
                    // TODO: Implement expand all
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Tree view
            if let rootNode = rootNode {
                ListTreeView(root: rootNode)
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
        
        // Parse JSON to build tree
        if fileInfo.isValidJSON {
            do {
                let data = Data(jsonText.utf8)
                rootNode = try JSONTreeBuilder.build(from: data)
            } catch {
                showError("Failed to parse JSON: \(error.localizedDescription)")
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
