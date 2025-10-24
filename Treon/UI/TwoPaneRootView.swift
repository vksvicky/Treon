//
//  TwoPaneRootView.swift
//  Treon
//
//  Created by Vivek on 2024-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import SwiftUI
import OSLog

public struct TwoPaneRootView: View {
    @State private var inputText: String = "{\n  \"hello\": true,\n  \"arr\": [1,2]\n}"
    @State private var root: JSONNode? = nil
    private let logger = Loggers.ui

    public init() {}

    public var body: some View {
        VStack {
            Text("Treon - JSON Formatter")
                .font(.largeTitle)
                .padding()

            Text("Welcome to Treon!")
                .font(.headline)
                .padding()

            Text("This is a simple test to see if the app loads correctly.")
                .padding()

            Button("Test Button") {
                logger.info("Button clicked!")
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func parseAndFormat() {
        do {
            let data = Data(inputText.utf8)
            let pretty = try JSONFormatter().prettyPrinted(from: data)
            inputText = String(decoding: pretty, as: UTF8.self)
            root = try JSONTreeBuilder.build(from: pretty)
        } catch {
            // keep simple for scaffold
        }
    }

    private func minify() {
        do {
            let data = Data(inputText.utf8)
            let min = try JSONFormatter().minified(from: data)
            inputText = String(decoding: min, as: UTF8.self)
            root = try JSONTreeBuilder.build(from: min)
        } catch {
        }
    }
}

struct ListTreeView: View {
    let root: JSONNode?
    @ObservedObject var expansion: TreeExpansionState

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if let root {
                        NodeRow(node: root, expansion: expansion, isLastChild: true, depth: 0)
                            .id("root")
                    }
                }
                .padding(.horizontal, 8)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .onChange(of: root?.id) {
                // Scroll to top when root changes (new file loaded)
                if root != nil {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("root", anchor: .top)
                    }
                }
            }
        }
    }
}

struct NodeRow: View {
    let node: JSONNode
    @ObservedObject var expansion: TreeExpansionState
    let isLastChild: Bool
    let depth: Int

    init(node: JSONNode, expansion: TreeExpansionState, isLastChild: Bool = true, depth: Int = 0) {
        self.node = node
        self._expansion = ObservedObject(wrappedValue: expansion)
        self.isLastChild = isLastChild
        self.depth = depth
    }

    var title: String { node.displayTitle }

    // Tree spacing - clean indentation without lines
    @ViewBuilder
    private var treeSpacing: some View {
        // Simple spacing based on depth - no visual lines
        HStack(spacing: 0) {
            if depth > 0 {
                Spacer()
                    .frame(width: CGFloat(depth * 6)) // 6 points per depth level
            }
        }
    }

    // Xcode-style icons and colors
    private func iconSystemName(for value: JSONNodeValue) -> String {
        switch value {
        case .string: return "textformat.abc"
        case .number: return "number"
        case .bool: return "checkmark.circle.fill"
        case .object: return "curlybraces"
        case .array: return "list.bullet.rectangle"
        case .null: return "circle.slash"
        }
    }

    private func iconColor(for value: JSONNodeValue) -> Color {
        switch value {
        case .string: return Color(red: 0.8, green: 0.4, blue: 0.2) // Orange
        case .number: return Color(red: 0.2, green: 0.6, blue: 0.8) // Blue
        case .bool: return Color(red: 0.2, green: 0.7, blue: 0.3) // Green
        case .object: return Color(red: 0.6, green: 0.3, blue: 0.8) // Purple
        case .array: return Color(red: 0.3, green: 0.7, blue: 0.8) // Cyan
        case .null: return Color(red: 0.5, green: 0.5, blue: 0.5) // Gray
        }
    }

    var body: some View {
        content
            .contextMenu {
                Button("Expand") { expansion.expand(node: node, includeDescendants: false) }
                Button("Expand with Children") { expansion.expand(node: node, includeDescendants: true) }
                Button("Collapse") { expansion.collapse(node: node, includeDescendants: false) }
                Button("Collapse with Children") { expansion.collapse(node: node, includeDescendants: true) }
            }
    }

    @ViewBuilder
    private var content: some View {
        HStack(spacing: 0) {
            // Clean tree spacing without lines
            treeSpacing
            
            // Main content
            VStack(spacing: 0) {
            switch node.value {
            case .object, .array:
                DisclosureGroup(isExpanded: Binding(
                    get: { expansion.isExpanded(node) },
                    set: { expansion.setExpanded($0, for: node) }
                )) {
                    // Virtualized rendering for all collections - no truncation
                    // SwiftUI's LazyVStack automatically handles virtualization for large lists
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(node.children.enumerated()), id: \.element.id) { index, child in
                            NodeRow(
                                node: child, 
                                expansion: expansion,
                                isLastChild: index == node.children.count - 1,
                                depth: depth + 1
                            )
                        }
                    }
                } label: {
                    HStack(spacing: 0) {
                        // Column 1: Icon + Key (Xcode-style)
                        HStack(spacing: 4) {
                            Group {
                                if let image = NSImage(named: node.typeIconName) {
                                    Image(nsImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                } else {
                                    // Xcode-style SF Symbols
                                    Image(systemName: iconSystemName(for: node.value))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(iconColor(for: node.value))
                                }
                            }
                            Text(title)
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .font(.system(size: 13, weight: .regular))
                                .help(title)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)

                        // Column 2: Type (Xcode-style)
                        Text(node.enhancedDataType)
                            .foregroundColor(.secondary)
                            .font(.system(size: 11, weight: .regular))
                            .frame(width: 60, alignment: .trailing)
                            .padding(.trailing, 8)
                    }
                }
            case .string(let stringValue):
                HStack(spacing: 0) {
                // Column 1: Icon + Key: Value (Xcode-style)
                HStack(spacing: 4) {
                    Group {
                        if let image = NSImage(named: node.typeIconName) {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        } else {
                            // Xcode-style SF Symbols
                            Image(systemName: iconSystemName(for: node.value))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(iconColor(for: node.value))
                        }
                    }
                    Text("\(title): \"\(stringValue)\"")
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .font(.system(size: 13, weight: .regular))
                        .help("\(title): \"\(stringValue)\"")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)

                // Column 2: Type (Xcode-style)
                Text(node.enhancedDataType)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular))
                    .frame(width: 60, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            case .number(let numberValue):
                HStack(spacing: 0) {
                // Column 1: Icon + Key: Value (Xcode-style)
                HStack(spacing: 4) {
                    Group {
                        if let image = NSImage(named: node.typeIconName) {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        } else {
                            // Xcode-style SF Symbols
                            Image(systemName: iconSystemName(for: node.value))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(iconColor(for: node.value))
                        }
                    }
                    Text("\(title): \(numberValue)")
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .font(.system(size: 13, weight: .regular))
                        .help("\(title): \(numberValue)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)

                // Column 2: Type (Xcode-style)
                Text(node.enhancedDataType)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular))
                    .frame(width: 60, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            case .bool(let boolValue):
                HStack(spacing: 0) {
                // Column 1: Icon + Key: Value (Xcode-style)
                HStack(spacing: 4) {
                    Group {
                        if let image = NSImage(named: node.typeIconName) {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        } else {
                            // Xcode-style SF Symbols
                            Image(systemName: iconSystemName(for: node.value))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(iconColor(for: node.value))
                        }
                    }
                    Text("\(title): \(boolValue ? "true" : "false")")
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .font(.system(size: 13, weight: .regular))
                        .help("\(title): \(boolValue ? "true" : "false")")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)

                // Column 2: Type (Xcode-style)
                Text(node.enhancedDataType)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular))
                    .frame(width: 60, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            case .null:
                HStack(spacing: 0) {
                // Column 1: Icon + Key: Value (Xcode-style)
                HStack(spacing: 4) {
                    Group {
                        if let image = NSImage(named: node.typeIconName) {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        } else {
                            // Xcode-style SF Symbols
                            Image(systemName: iconSystemName(for: node.value))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(iconColor(for: node.value))
                        }
                    }
                    Text("\(title): null")
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .font(.system(size: 13, weight: .regular))
                        .help("\(title): null")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)

                // Column 2: Type (Xcode-style)
                Text(node.enhancedDataType)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular))
                    .frame(width: 60, alignment: .trailing)
                    .padding(.trailing, 8)
                }
            }
            }
        }
    }
}