//
//  CppJSONTreeView.swift
//  Treon
//
//  SwiftUI view for displaying JSON tree using C++ backend
//

import SwiftUI

struct CppJSONTreeView: View {
    @StateObject private var backend = CppBackend()
    @State private var jsonNodes: [CppJSONNode] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedNode: CppJSONNode?
    @State private var expandedNodes: Set<String> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Search bar
            searchView
            
            // Content
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if jsonNodes.isEmpty {
                emptyView
            } else {
                treeView
            }
            
            // Performance stats
            if backend.isConnected {
                performanceStatsView
            }
        }
        .onAppear {
            Task {
                await checkBackendConnection()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            Text("JSON Tree View (C++ Backend)")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Backend status
            HStack(spacing: 4) {
                Circle()
                    .fill(backend.isConnected ? .green : .red)
                    .frame(width: 8, height: 8)
                
                Text(backend.isConnected ? "C++ Backend Connected" : "Backend Disconnected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Search View
    
    private var searchView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search JSON...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    Task {
                        await performSearch()
                    }
                }
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    Task {
                        await loadCurrentData()
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Processing JSON...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await checkBackendConnection()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No JSON Data")
                .font(.headline)
            
            Text("Load a JSON file to see the tree structure")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Load Sample JSON") {
                Task {
                    await loadSampleJSON()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Tree View
    
    private var treeView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(jsonNodes) { node in
                    CppTreeNodeView(
                        node: node,
                        isExpanded: expandedNodes.contains(node.path),
                        onToggle: { toggleNode(node) },
                        onSelect: { selectNode(node) }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Performance Stats View
    
    private var performanceStatsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Performance Stats (C++)")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("Memory: \(String(format: "%.1f", backend.performanceStats.memoryUsageMB)) MB")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Cache: \(backend.performanceStats.cacheSize) items")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Nodes: \(backend.performanceStats.totalNodes)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Refresh Stats") {
                Task {
                    _ = try? await backend.getPerformanceStats()
                }
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Actions
    
    private func checkBackendConnection() async {
        do {
            let isConnected = try await backend.ping()
            await MainActor.run {
                if isConnected {
                    errorMessage = nil
                } else {
                    errorMessage = "Failed to connect to C++ backend"
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadSampleJSON() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let sampleJSON = """
        {
            "users": [
                {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com",
                    "profile": {
                        "age": 30,
                        "city": "New York",
                        "preferences": {
                            "theme": "dark",
                            "notifications": true
                        }
                    }
                },
                {
                    "id": 2,
                    "name": "Jane Smith",
                    "email": "jane@example.com",
                    "profile": {
                        "age": 25,
                        "city": "San Francisco",
                        "preferences": {
                            "theme": "light",
                            "notifications": false
                        }
                    }
                }
            ],
            "metadata": {
                "version": "1.0",
                "created": "2025-01-18"
            }
        }
        """
        
        do {
            let result = try await backend.loadFromString(sampleJSON)
            await MainActor.run {
                if result.success {
                    jsonNodes = result.tree ?? []
                } else {
                    errorMessage = result.error ?? "Unknown error"
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func loadCurrentData() async {
        // Reload current data without search
        // This would typically reload the original JSON
        // For now, we'll just clear the search
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let result = try await backend.search(searchText)
            await MainActor.run {
                if result.success {
                    jsonNodes = result.results
                } else {
                    errorMessage = "Search failed"
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func toggleNode(_ node: CppJSONNode) {
        if expandedNodes.contains(node.path) {
            expandedNodes.remove(node.path)
        } else {
            expandedNodes.insert(node.path)
        }
    }
    
    private func selectNode(_ node: CppJSONNode) {
        selectedNode = node
    }
}

// MARK: - CppTreeNode View

struct CppTreeNodeView: View {
    let node: CppJSONNode
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Expand/collapse button
                if !node.children.isEmpty {
                    Button(action: onToggle) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 16, height: 16)
                } else {
                    Spacer()
                        .frame(width: 16, height: 16)
                }
                
                // Node icon
                Image(systemName: iconForType(node.type))
                    .font(.caption)
                    .foregroundColor(colorForType(node.type))
                    .frame(width: 16)
                
                // Node key
                Text(node.key)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                
                // Node value
                if !node.children.isEmpty {
                    Text("(\(node.children.count) items)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(formatValue(node.value))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
            
            // Children
            if isExpanded && !node.children.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(node.children) { child in
                        CppTreeNodeView(
                            node: child,
                            isExpanded: false, // Children start collapsed
                            onToggle: { },
                            onSelect: { }
                        )
                        .padding(.leading, 20)
                    }
                }
            }
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "string":
            return "text.quote"
        case "int", "double", "float":
            return "number"
        case "bool":
            return "checkmark.circle"
        case "array":
            return "list.bullet"
        case "object":
            return "curlybraces"
        default:
            return "questionmark.circle"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "string":
            return .green
        case "int", "double", "float":
            return .blue
        case "bool":
            return .orange
        case "array":
            return .purple
        case "object":
            return .red
        default:
            return .gray
        }
    }
    
    private func formatValue(_ value: AnyCodable) -> String {
        switch value.value {
        case let string as String:
            return "\"\(string)\""
        case let int as Int:
            return "\(int)"
        case let double as Double:
            return String(format: "%.2f", double)
        case let bool as Bool:
            return bool ? "true" : "false"
        case let array as [Any]:
            return "[\(array.count) items]"
        case let dict as [String: Any]:
            return "{\(dict.count) items}"
        default:
            return String(describing: value.value)
        }
    }
}

// MARK: - Preview

struct CppJSONTreeView_Previews: PreviewProvider {
    static var previews: some View {
        CppJSONTreeView()
            .frame(width: 600, height: 400)
    }
}
