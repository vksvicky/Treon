//
//  TabbedJSONViewerView.swift
//  Treon
//
//  Created by AI Assistant on 2024-12-19.
//  Copyright © 2024 Treon. All rights reserved.
//

import SwiftUI
import AppKit

struct TabbedJSONViewerView: View {
    @StateObject private var tabManager = TabManager.shared
    @StateObject private var fileManager = TreonFileManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            tabBar
            
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
        }
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            // Tab buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabManager.tabs) { tab in
                        TabButton(
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
            
            // Tab actions
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
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderless)
                .help("Open New File")
                
                if tabManager.tabCount > 1 {
                    Button(action: {
                        tabManager.closeAllTabs()
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .help("Close All Tabs")
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 32)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct TabButton: View {
    let tab: TabInfo
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 4) {
            // Tab icon
            Image(systemName: "doc.text")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isActive ? .primary : .secondary)
            
            // Tab title
            Text(tab.name)
                .font(.system(size: 12, weight: .medium))
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
            .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
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
