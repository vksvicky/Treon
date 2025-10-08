import SwiftUI
import UniformTypeIdentifiers
import AppKit
import os.log

struct LaunchScreenView: View {
    @StateObject private var fileManager = TreonFileManager.shared
    @StateObject private var permissionManager = PermissionManager.shared
    @State private var showingRecentFiles = false
    @State private var showingURLInput = false
    @State private var showingCurlInput = false
    @State private var urlInput = ""
    @State private var curlInput = ""
    
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "LaunchScreenView")

    var body: some View {
        Group {
            if fileManager.currentFile != nil {
                // Show JSON viewer when a file is loaded
                JSONViewerView()
            } else {
                // Show launch screen when no file is loaded
                VStack(spacing: 40) {
                    header
                    actions
                    recentFiles
                    errorBanner
                    dragAndDropHint
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleFileDrop(providers: providers)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            Text("Treon")
                .font(.system(size: 48, weight: .light, design: .default))
                .foregroundColor(.primary)
            Text("JSON Formatter & Viewer")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
        }
    }

    private var actions: some View {
        VStack(spacing: 20) {
            primaryActions
            secondaryActions
            tertiaryActions
            inputsSection
        }
    }

    private var primaryActions: some View {
        HStack(spacing: DesignConstants.buttonSpacing) {
            Button(action: openFile) {
                HStack {
                    if fileManager.isLoading {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(fileManager.isLoading ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: fileManager.isLoading)
                    } else {
                        Image(systemName: "folder")
                    }
                    Text("Open File")
                }
            }
            .buttonStyle(StandardButtonStyle(backgroundColor: .blue, foregroundColor: .white, isOutlined: false))
            .disabled(fileManager.isLoading)
            Button(action: newFile) {
                HStack { Image(systemName: "doc.badge.plus"); Text("New File") }
            }
            .buttonStyle(StandardButtonStyle(backgroundColor: .blue, foregroundColor: .blue, isOutlined: true))
            .disabled(fileManager.isLoading)
        }
    }

    private var secondaryActions: some View {
        HStack(spacing: DesignConstants.buttonSpacing) {
            Button(action: newFromPasteboard) { HStack { Image(systemName: "doc.on.clipboard"); Text("From Pasteboard") } }
                .buttonStyle(StandardButtonStyle(backgroundColor: .green, foregroundColor: .green, isOutlined: true))
                .disabled(fileManager.isLoading)
            Button(action: { showingURLInput.toggle() }) { HStack { Image(systemName: "link"); Text("From URL") } }
                .buttonStyle(StandardButtonStyle(backgroundColor: .orange, foregroundColor: .orange, isOutlined: true))
                .disabled(fileManager.isLoading)
        }
    }

    private var tertiaryActions: some View {
        HStack(spacing: DesignConstants.buttonSpacing) {
            Button(action: { showingCurlInput.toggle() }) { HStack { Image(systemName: "terminal"); Text("From cURL") } }
                .buttonStyle(StandardButtonStyle(backgroundColor: .purple, foregroundColor: .purple, isOutlined: true))
                .disabled(fileManager.isLoading)
            Spacer().frame(width: DesignConstants.buttonWidth, height: DesignConstants.buttonHeight)
        }
    }

    private var inputsSection: some View {
        VStack(spacing: 8) {
            if showingURLInput { urlInputView.padding(.top, 10) } else { Spacer().frame(height: showingCurlInput ? 0 : 60) }
            if showingCurlInput { curlInputView.padding(.top, 10) } else { Spacer().frame(height: showingURLInput ? 0 : 60) }
        }.frame(height: 120)
    }

    private var urlInputView: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Enter URL...", text: $urlInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
                Button("Load") { loadFromURL() }
                    .buttonStyle(.borderedProminent)
                    .disabled(urlInput.isEmpty || fileManager.isLoading)
            }
            Button("Cancel") { showingURLInput = false; urlInput = "" }
                .buttonStyle(.bordered)
        }
    }

    private var curlInputView: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enter cURL command:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("curl -X GET https://api.example.com/data", text: $curlInput, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 400, height: 60)
            }
            HStack {
                Button("Execute") { executeCurlCommand() }
                    .buttonStyle(.borderedProminent)
                    .disabled(curlInput.isEmpty || fileManager.isLoading)
                Button("Cancel") { showingCurlInput = false; curlInput = "" }
                    .buttonStyle(.bordered)
            }
        }
    }

    private var recentFiles: some View {
        Group {
            if !fileManager.recentFiles.isEmpty {
                VStack(spacing: 12) {
                    Button(action: { showingRecentFiles.toggle() }) {
                        HStack { Text("Recent Files").font(.headline); Image(systemName: showingRecentFiles ? "chevron.up" : "chevron.down") }
                            .foregroundColor(.blue)
                    }.buttonStyle(PlainButtonStyle())
                    if showingRecentFiles {
                        VStack(spacing: 8) {
                            ForEach(fileManager.recentFiles.prefix(5)) { recentFile in
                                RecentFileRow(recentFile: recentFile) { openRecentFile(recentFile) }
                            }
                        }.padding(.horizontal)
                    }
                }.padding(.top, 20)
            }
        }
    }

    private var errorBanner: some View {
        Group {
            if let errorMessage = fileManager.errorMessage {
                // Check if this is a permission error
                if errorMessage.contains("permission") || errorMessage.contains("Permission") {
                    permissionRequestBanner
                } else {
                    // Show regular error message for non-permission errors
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    private var permissionRequestBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("File Access Permission Required")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Text("Treon needs permission to access files on your system. This is required to open files from Recent Files.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button("Grant Permission") {
                    Task {
                        let granted = await permissionManager.requestFileAccessPermission()
                        if granted {
                            logger.info("Permission granted from error banner")
                            // Clear the error and try to open the file again
                            fileManager.clearError()
                            // The file should now be accessible
                        } else {
                            logger.info("Permission denied from error banner")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Reject") {
                    logger.info("Permission request rejected from error banner")
                    fileManager.clearError()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private var dragAndDropHint: some View {
        VStack(spacing: 8) {
            Text("or").font(.system(size: 14)).foregroundColor(.secondary)
            HStack {
                Image(systemName: "arrow.down.circle").foregroundColor(.secondary)
                Text("Drag and drop a JSON file here").font(.system(size: 14)).foregroundColor(.secondary)
            }
        }
    }

    private func openFile() {
        Task {
            do {
                fileManager.isLoading = true
                fileManager.clearError()
                let fileInfo = try await fileManager.openFile()
                fileManager.currentFile = fileInfo
                logger.info("Successfully opened file: \(fileInfo.name)")
            } catch {
                // Only show error if it's not a user cancellation
                if let fileManagerError = error as? FileManagerError,
                   case .userCancelled = fileManagerError {
                    logger.info("User cancelled file selection")
                } else {
                    // Clear the current file so we show the landing screen instead of JSON viewer
                    fileManager.currentFile = nil
                    fileManager.setError(error)
                    logger.error("Error opening file: \(error.localizedDescription)")
                }
            }
            fileManager.isLoading = false
        }
    }

    private func newFile() {
        let fileInfo = fileManager.createNewFile()
        fileManager.currentFile = fileInfo
        logger.info("Created new file: \(fileInfo.name)")
    }

    private func openRecentFile(_ recentFile: RecentFile) {
        Task {
            do {
                fileManager.isLoading = true
                fileManager.clearError()
                logger.info("Attempting to open recent file: \(recentFile.url.path)")
                let fileInfo = try await fileManager.openFile(url: recentFile.url)
                logger.info("Successfully got file info, setting current file")
                fileManager.currentFile = fileInfo
                logger.info("Successfully opened recent file: \(fileInfo.name)")
            } catch {
                logger.error("Error caught in openRecentFile: \(error.localizedDescription)")
                logger.debug("Error type: \(type(of: error))")
                // Only show error if it's not a user cancellation
                if let fileManagerError = error as? FileManagerError,
                   case .userCancelled = fileManagerError {
                    logger.info("User cancelled file selection")
                } else {
                    // Clear the current file so we show the landing screen instead of JSON viewer
                    logger.info("Clearing current file and setting error")
                    fileManager.currentFile = nil
                    fileManager.setError(error)
                    logger.error("Error opening recent file: \(error.localizedDescription)")
                }
            }
            fileManager.isLoading = false
        }
    }

    private func newFromPasteboard() {
        Task {
            do {
                fileManager.isLoading = true
                fileManager.clearError()

                // Get content from pasteboard
                let pasteboard = NSPasteboard.general
                guard let content = pasteboard.string(forType: .string), !content.isEmpty else {
                    fileManager.setError(FileManagerError.invalidJSON("No content found in pasteboard"))
                    fileManager.isLoading = false
                    return
                }

                // Create file from pasteboard content (even if not valid JSON)
                let fileInfo = try await fileManager.createFileFromContent(content, name: "Pasteboard Content")
                fileManager.currentFile = fileInfo

                if fileInfo.isValidJSON {
                    logger.info("Successfully created JSON file from pasteboard: \(fileInfo.name)")
                } else {
                    logger.info("Created file from pasteboard (not valid JSON): \(fileInfo.name)")
                    // Don't show error for non-JSON content, just log it
                }
            } catch {
                // Clear the current file so we show the landing screen instead of JSON viewer
                fileManager.currentFile = nil
                fileManager.setError(error)
                logger.error("Error creating file from pasteboard: \(error.localizedDescription)")
            }
            fileManager.isLoading = false
        }
    }

    private func loadFromURL() {
        Task {
            do {
                fileManager.isLoading = true
                fileManager.clearError()

                guard let url = URL(string: urlInput) else {
                    fileManager.setError(FileManagerError.invalidJSON("Invalid URL format"))
                    fileManager.isLoading = false
                    return
                }

                // Load content from URL
                let fileInfo = try await fileManager.loadFromURL(url)
                fileManager.currentFile = fileInfo
                logger.info("Successfully loaded from URL: \(fileInfo.name)")

                // Clear the input and hide the section
                urlInput = ""
                showingURLInput = false
            } catch {
                // Clear the current file so we show the landing screen instead of JSON viewer
                fileManager.currentFile = nil
                fileManager.setError(error)
                logger.error("Error loading from URL: \(error.localizedDescription)")
            }
            fileManager.isLoading = false
        }
    }

    private func executeCurlCommand() {
        Task {
            do {
                fileManager.isLoading = true
                fileManager.clearError()

                // Parse and execute cURL command
                let fileInfo = try await fileManager.executeCurlCommand(curlInput)
                fileManager.currentFile = fileInfo
                logger.info("Successfully executed cURL command: \(fileInfo.name)")

                // Clear the input and hide the section
                curlInput = ""
                showingCurlInput = false
            } catch {
                // Clear the current file so we show the landing screen instead of JSON viewer
                fileManager.currentFile = nil
                fileManager.setError(error)
                logger.error("Error executing cURL command: \(error.localizedDescription)")
            }
            fileManager.isLoading = false
        }
    }

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            Task {
                                do {
                                    fileManager.isLoading = true
                                    fileManager.clearError()
                                    let fileInfo = try await fileManager.openFile(url: url)
                                    fileManager.currentFile = fileInfo
                                    logger.info("Successfully opened dropped file: \(fileInfo.name)")
                                } catch {
                                    // Clear the current file so we show the landing screen instead of JSON viewer
                                    fileManager.currentFile = nil
                                    fileManager.setError(error)
                                    logger.error("Error opening dropped file: \(error.localizedDescription)")
                                }
                                fileManager.isLoading = false
                            }
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}


// MARK: - Recent File Row Component
struct RecentFileRow: View {
    let recentFile: RecentFile
    let onTap: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: recentFile.isValidJSON ? "doc.text" : "doc.text.badge.exclamationmark")
                    .foregroundColor(recentFile.isValidJSON ? .blue : .orange)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(recentFile.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack {
                        Text(recentFile.formattedSize)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(recentFile.lastOpened, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if !recentFile.isValidJSON {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isHovering ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    LaunchScreenView()
        .frame(width: 600, height: 400)
}
