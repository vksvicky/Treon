//
//  SettingsView.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import SwiftUI
import AppKit
import OSLog

struct SettingsView: View {
    @StateObject private var permissionManager = PermissionManager.shared
    @StateObject private var fileManager = TreonFileManager.shared
    @StateObject private var settings = UserSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "SettingsView")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
                HStack {
                    Text("Settings")
                    .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Content - compact, left-aligned, no scrolling
            VStack(alignment: .leading, spacing: 4) {
                    // File Access Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("File Access")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                                Circle()
                                .fill(permissionManager.permissionStatus == .granted ? Color.green : 
                                      permissionManager.permissionStatus == .needsUserAction ? Color.orange : Color.red)
                                .frame(width: 8, height: 8)

                                Text(permissionManager.permissionStatusMessage)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                        }
                        
                        if permissionManager.permissionStatus == .needsUserAction {
                            Text("Select directories to grant Treon access to JSON files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)
                        } else if permissionManager.permissionStatus == .granted && !permissionManager.grantedDirectories.isEmpty {
                            let dirNames = permissionManager.grantedDirectories.map { $0.lastPathComponent }.joined(separator: ", ")
                            Text("Accessible directories: \(dirNames)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        if permissionManager.permissionStatus == .needsUserAction {
                                Button("Grant Permission") {
                                logger.info("SettingsView: Grant Permission button clicked")
                                // Add a small delay to ensure settings window is fully visible
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    Task {
                                        logger.info("SettingsView: About to request file access permission")
                                        let granted = await permissionManager.requestFileAccessPermission()
                                        if granted {
                                            logger.info("Directory access granted from settings")
                                        } else {
                                            logger.info("Directory access denied from settings")
                                        }
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        } else if permissionManager.permissionStatus == .granted {
                            Button("Add More Directories") {
                                Task {
                                    let granted = await permissionManager.addDirectoryAccess()
                                    if granted {
                                        logger.info("Additional directory access granted")
                                    } else {
                                        logger.info("Additional directory access denied")
                                    }
                                }
                                }
                                .buttonStyle(.bordered)
                            .controlSize(.small)
                            
                            Button("Revoke Access") {
                                permissionManager.revokeAllPermissions()
                                logger.info("All directory access revoked")
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .foregroundColor(.red)
                        }

                        Button("System Settings") {
                            permissionManager.openSystemPrivacySettings()
                            }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        }
                    }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                    // Recent Files Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Files")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                            HStack {
                                Text("\(fileManager.recentFiles.count) files")
                                    .font(.body)
                                    .foregroundColor(.secondary)

                                Spacer()

                                Button("Clear All") {
                                    fileManager.clearAllRecentFiles()
                                    logger.info("Recent files cleared from settings")
                                }
                                .buttonStyle(.bordered)
                        .controlSize(.small)
                                .foregroundColor(.red)
                                .disabled(fileManager.recentFiles.isEmpty)
                            }

                            Toggle("Clear recent files on quit", isOn: $settings.clearRecentFilesOnQuit)
                                .help("Remove all recent files when quitting the app")
                        }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                    // Preferences Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preferences")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    // JSON Processing
                    VStack(alignment: .leading, spacing: 3) {
                                Text("JSON Processing")
                                    .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                                        HStack {
                            Text("Max Depth:")
                                            Spacer()
                            
                                            if settings.maxDepth == 0 {
                                                Text("Unlimited")
                                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                                            } else {
                                HStack(spacing: 6) {
                                            Slider(value: Binding(
                                                get: { Double(settings.maxDepth) },
                                                set: { settings.maxDepth = Int($0) }
                                    ), in: 3...10, step: 1) {
                                        Text("\(settings.maxDepth)")
                                            .frame(width: 20)
                                        }
                                    .frame(width: 80)
                                }
                            }
                            
                            Button(settings.maxDepth == 0 ? "Limited" : "Unlimited") {
                                                if settings.maxDepth == 0 {
                                                    settings.maxDepth = 3
                                                } else {
                                                    settings.maxDepth = 0
                                                }
                                            }
                                            .buttonStyle(.bordered)
                                            .controlSize(.small)
                                    }
                                    .help("Maximum depth for JSON tree parsing (3-10, or unlimited)")

                                    Toggle("Auto-format on open", isOn: $settings.autoFormatOnOpen)
                                        .help("Automatically format JSON when opening files")

                        // Toggle("Show line numbers", isOn: $settings.showLineNumbers)
                        //     .help("Display line numbers in the JSON editor")
                        
                        Toggle("Wrap text", isOn: $settings.wrapText)
                            .help("Wrap long lines in the JSON editor")
                    }
                    
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
            .padding(.horizontal, 16)
            
                                        Spacer()

            // Bottom buttons - aligned
                                    HStack {
                                        Button("Reset to Defaults") {
                                            settings.resetToDefaults()
                                        }
                                        .buttonStyle(.bordered)
                                        .help("Reset all settings to their default values")
                
                    Spacer()
                
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 520, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            logger.info("SettingsView: onAppear called")
            permissionManager.checkFileAccessPermission()
            logger.info("SettingsView: permission check completed")
        }
    }

    // MARK: - Helper Methods

    private func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    SettingsView()
}
