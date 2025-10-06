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
        if let k = node.key { return k }
        return "$"
    }

    var body: some View {
        DisclosureGroup(title) {
            ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                NodeRow(node: child)
            }
        }
    }
}


