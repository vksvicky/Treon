import SwiftUI
import AppKit
import OSLog

struct SettingsView: View {
    @StateObject private var permissionManager = PermissionManager.shared
    @StateObject private var fileManager = TreonFileManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "SettingsView")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                header
                permissionsSection
                recentFilesSection
                Spacer()
                footer
            }
            .padding(20)
            .frame(width: 500, height: 400)
        }
        .navigationTitle("Settings")
        .onAppear {
            permissionManager.checkFileAccessPermission()
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "gear")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text("Treon Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Manage your application preferences and permissions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("File Access")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Circle()
                            .fill(permissionManager.hasFileAccessPermission ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(permissionManager.permissionStatusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button("Grant Permission") {
                        Task {
                            let granted = await permissionManager.requestFileAccessPermission()
                            if granted {
                                logger.info("Permission granted from settings")
                            } else {
                                logger.info("Permission denied from settings")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(permissionManager.hasFileAccessPermission)
                    
                    Button("System Settings") {
                        permissionManager.openSystemPrivacySettings()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    private var recentFilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Files")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Clear All") {
                    fileManager.clearRecentFiles()
                    logger.info("Recent files cleared from settings")
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
            
            if fileManager.recentFiles.isEmpty {
                Text("No recent files")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(fileManager.recentFiles.enumerated()), id: \.element.url) { index, recentFile in
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recentFile.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    
                                    Text("\(formatFileSize(recentFile.size)) • \(formatTimeAgo(recentFile.lastOpened))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button("Remove") {
                                    fileManager.removeRecentFile(recentFile)
                                    logger.info("Removed recent file: \(recentFile.name)")
                                }
                                .buttonStyle(.borderless)
                                .font(.caption2)
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                        }
                    }
                }
                .frame(maxHeight: 120)
            }
        }
    }
    
    private var footer: some View {
        HStack {
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    SettingsView()
}
