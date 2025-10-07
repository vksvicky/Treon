import SwiftUI

public struct TwoPaneRootView: View {
    @State private var inputText: String = "{\n  \"hello\": true,\n  \"arr\": [1,2]\n}"
    @State private var root: JSONNode? = nil

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
                print("Button clicked!")
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
        List {
            if let root {
                NodeRow(node: root, expansion: expansion)
            }
        }
        .listStyle(.inset)
    }
}

struct NodeRow: View {
    let node: JSONNode
    @ObservedObject var expansion: TreeExpansionState

    init(node: JSONNode, expansion: TreeExpansionState) {
        self.node = node
        self._expansion = ObservedObject(wrappedValue: expansion)
    }

    var title: String { node.displayTitle }

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
        switch node.value {
        case .object, .array:
            DisclosureGroup(isExpanded: Binding(
                get: { expansion.isExpanded(node) },
                set: { expansion.setExpanded($0, for: node) }
            )) {
                ForEach(node.children) { child in
                    NodeRow(node: child, expansion: expansion)
                }
            } label: {
                Text(title)
            }
        case .string(let s):
            HStack {
                Text(title)
                Spacer()
                Text("\"\(s)\"")
                    .foregroundColor(.secondary)
            }
        case .number(let n):
            HStack {
                Text(title)
                Spacer()
                Text(String(n))
                    .foregroundColor(.secondary)
            }
        case .bool(let b):
            HStack {
                Text(title)
                Spacer()
                Text(b ? "true" : "false")
                    .foregroundColor(.secondary)
            }
        case .null:
            HStack {
                Text(title)
                Spacer()
                Text("null")
                    .foregroundColor(.secondary)
            }
        }
    }
}


