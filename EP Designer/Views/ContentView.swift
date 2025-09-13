//
//  MainView.swift
//  EP Designer
//
//  Created by David Mann on 6/18/25.
//

import SwiftUI

// ----------------------------
// UI helpers
// ----------------------------
struct NodeLabel: View {
    let node: DecisionNode
    let prefix: String?

    init(node: DecisionNode, prefix: String? = nil) {
        self.node = node
        self.prefix = prefix
    }

    var body: some View {
        HStack {
            if let p = prefix {
                Text(p + ":")
                    .foregroundColor(.secondary)
            }
            Text(node.question ?? node.result ?? "Untitled")
                .lineLimit(1)
        }
    }
}

struct NodeDetailView: View {
    let node: DecisionNode

    var body: some View {
        Form {
            if let q = node.question {
                Section("Question") { Text(q) }
            }
            if let r = node.result {
                Section("Result") { Text(r) }
            }
            if let note = node.note {
                Section("Note") { Text(note) }
            }
            if let tag = node.tag {
                Section("Tag") { Text(tag) }
            }
            if let branches = node.branches {
                Section("Branches") {
                    Text("\(branches.count) branch(es)")
                }
            }
        }
        .navigationTitle(node.question ?? node.result ?? "Node")
    }
}

// MARK: Recursive sidebar builder
struct NodeListView: View {
    let node: DecisionNode
    @Binding var selection: DecisionNode?   // uses DecisionNode (Hashable)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Make the node selectable
            NavigationLink(tag: node, selection: $selection) {
                NodeDetailView(node: node)
            } label: {
                NodeLabel(node: node)
            }

            // Render children
            if let branches = node.branches {
                ForEach(branches.sorted(by: { $0.key < $1.key }), id: \.key) { key, child in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("\(key):").foregroundColor(.secondary)
                            NavigationLink(value: child) {
                                NodeLabel(node: child, prefix: key)
                            }
                            NavigationLink(tag: child, selection: $selection) {
                                NodeDetailView(node: child)
                            } label: {
                                NodeLabel(node: child)
                            }
                        }
                        .padding(.leading, 12)

                        // Recurse for grandchildren (indent)
                        if child.branches != nil {
                            NodeListView(node: child, selection: $selection)
                                .padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
}


// ----------------------------
// Main content view
// ----------------------------
struct ContentView: View {
    @State private var selection: DecisionNode? = nil

    // sample data
    @State private var root: DecisionNode = {
        DecisionNode(
            id: DecisionNode.rootNodeId,
            question: "Favorite color?",
            branches: [
                "Red": DecisionNode(id: "node-red", result: "You like red!"),
                "Blue": DecisionNode(
                    id: "node-blue",
                    question: "Why blue?",
                    branches: [
                        "Sky": DecisionNode(id: "node-blue-sky", result: "Sky blue chosen."),
                        "Ocean": DecisionNode(id: "node-blue-ocean", result: "Ocean blue chosen.")
                    ]
                )
            ]
        )
    }()

    var body: some View {
        NavigationSplitView {
            // Sidebar — using a ScrollView + VStack (keeps the example simple)
            ScrollView {
                NodeListView(node: root, selection: $selection)
                    .padding()
            }
            .navigationTitle("Decision Tree")
        } detail: {
            // Detail pane: show the selected node (if any)
            if let selected = selection {
                NodeDetailView(node: selected)
            } else {
                // fallback / welcome view
                VStack {
                    Text("Select a node")
                        .foregroundColor(.secondary)
                    Text(root.question ?? "Root")
                        .font(.headline)
                }
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
