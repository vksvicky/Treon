//
//  RecentFilesView.swift
//  Treon
//
//  Created by Vivek on 2024-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import SwiftUI
import AppKit

struct RecentFilesView: View {
    @StateObject private var fileManager = TreonFileManager.shared
    @State private var showingRecentFiles = false

    let onFileSelected: (RecentFile) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { showingRecentFiles.toggle() }) {
                HStack {
                    Text("Recent Files")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Image(systemName: showingRecentFiles ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(.borderless)

            if showingRecentFiles {
                VStack(alignment: .leading, spacing: 6) {
                    if fileManager.recentFiles.isEmpty {
                        Text("No recent files")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    } else {
                        // Show first 5 files without scrolling
                        ForEach(Array(fileManager.recentFiles.prefix(5).enumerated()), id: \.element.url) { index, recentFile in
                            RecentFileRow(
                                recentFile: recentFile,
                                onTap: { onFileSelected(recentFile) }
                            )
                        }
                        
                        // If there are more than 5 files, show a scrollable section for the rest
                        if fileManager.recentFiles.count > 5 {
                            Divider()
                                .padding(.vertical, 4)
                            
                            Text("More files (\(fileManager.recentFiles.count - 5) remaining)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(fileManager.recentFiles.dropFirst(5).prefix(10).enumerated()), id: \.element.url) { index, recentFile in
                                        RecentFileRow(
                                            recentFile: recentFile,
                                            onTap: { onFileSelected(recentFile) }
                                        )
                                    }
                                }
                            }
                            .frame(maxHeight: 200) // Limit height to prevent the dropdown from becoming too large
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct RecentFileRow: View {
    let recentFile: RecentFile
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text("•")
                .foregroundColor(.secondary)
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(recentFile.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text("\(recentFile.formattedSize) • \(recentFile.lastOpened, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
