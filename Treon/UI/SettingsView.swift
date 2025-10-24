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
    @Environment(\.dismiss) private var dismiss

    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "SettingsView")

    var body: some View {
        VStack(spacing: 0) {
            // Content
            VStack(spacing: 24) {
                // File Access Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("File Access")
                            .font(.headline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(permissionManager.hasFileAccessPermission ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            
                            Text(permissionManager.permissionStatusMessage)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        HStack(spacing: 12) {
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
                            .controlSize(.regular)

                            Button("System Settings") {
                                permissionManager.openSystemPrivacySettings()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.regular)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                
                // Recent Files Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Files")
                            .font(.headline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
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
                        .controlSize(.regular)
                        .foregroundColor(.red)
                        .disabled(fileManager.recentFiles.isEmpty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Spacer()
            
            // Done Button
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 520, height: 320)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            permissionManager.checkFileAccessPermission()
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
