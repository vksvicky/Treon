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

    var body: some View {
        List {
            if let root {
                NodeRow(node: root)
            }
        }
        .listStyle(.inset)
    }
}

struct NodeRow: View {
    let node: JSONNode

    var title: String {
        // Handle root node (no key)
        guard let key = node.key else {
            switch node.value {
            case .object:
                return "Root Object"
            case .array:
                return "Root Array"
            default:
                return "Root"
            }
        }
        
        // Handle array indices - they should be displayed with brackets
        if let index = Int(key) {
            return "[\(index)]"
        }
        
        // Handle object keys - display as is
        return key
    }

    var body: some View {
        switch node.value {
        case .object, .array:
            DisclosureGroup(title) {
                ForEach(node.children) { child in
                    NodeRow(node: child)
                }
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


