import SwiftUI
import AppKit

struct RecentFilesView: View {
    @StateObject private var fileManager = TreonFileManager.shared
    @State private var showingRecentFiles = false
    
    let onFileSelected: (RecentFile) -> Void
    
    var body: some View {
        Group {
            if !fileManager.recentFiles.isEmpty {
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
                            // Show last 5 files in descending order (most recent first)
                            ForEach(Array(fileManager.recentFiles.prefix(5).enumerated()), id: \.element.url) { index, recentFile in
                                RecentFileRow(
                                    recentFile: recentFile,
                                    onTap: { onFileSelected(recentFile) }
                                )
                            }
                        }
                        .padding(.top, 8)
                    }
                }
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
