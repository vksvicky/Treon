//
//  TabbedJSONViewerView.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import SwiftUI
import AppKit

struct TabbedJSONViewerView: View {
    @StateObject private var tabManager = TabManager.shared
    @StateObject private var fileManager = TreonFileManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area
            if let activeTab = tabManager.activeTab {
                JSONViewerView(fileInfo: activeTab.fileInfo)
            } else {
                // Fallback content when no tabs are active
                VStack {
                    Spacer()
                    Text("No files open")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
            }
            
            // Status bar with tabs at the bottom
            statusBar
        }
        .onReceive(NotificationCenter.default.publisher(for: NotificationNames.openFileRequested)) { _ in
            Task {
                do {
                    _ = try await fileManager.openFile()
                } catch {
                    // Handle error if needed
                }
            }
        }
    }
    
    private var statusBar: some View {
        HStack(spacing: 0) {
            // Left side - File tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabManager.tabs) { tab in
                        StatusBarTabButton(
                            tab: tab,
                            isActive: tab.isActive,
                            onSelect: { tabManager.switchToTab(tab.id) },
                            onClose: { tabManager.closeTab(tab.id) }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Spacer()
            
            // Right side - Status info and actions
            HStack(spacing: 12) {
                // File count info
                Text("\(tabManager.tabCount) file\(tabManager.tabCount == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                // Action buttons
                HStack(spacing: 8) {
                    Button(action: {
                        Task {
                            do {
                                _ = try await fileManager.openFile()
                            } catch {
                                // Handle error if needed
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .help("Open New File (CMD+O)")
                    
                    if tabManager.tabCount > 1 {
                        Button(action: {
                            tabManager.closeAllTabs()
                        }) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .buttonStyle(.borderless)
                        .help("Close All Tabs")
                    }
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 24)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct StatusBarTabButton: View {
    let tab: TabInfo
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 4) {
            // Tab title
            Text(tab.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isActive ? .primary : .secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(isHovered ? .primary : .clear)
            }
            .buttonStyle(.borderless)
            .frame(width: 10, height: 10)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(isActive ? Color(NSColor.selectedControlColor) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
        .help(tab.name)
    }
}

#Preview {
    TabbedJSONViewerView()
        .frame(width: 800, height: 600)
}
