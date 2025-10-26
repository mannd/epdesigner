//
//  ContentView.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI

struct ContentView: View {
    @State var root: DecisionNode
    @State private var expanded: Set<String> = []
    @State private var selection: DecisionNode?

    var body: some View {
        NavigationStack {
            NavigationSplitView {
                // Sidebar
                ScrollView {
                    NodeListView(node: root, expanded: $expanded, selection: $selection)
                        .padding()
                        .navigationTitle("Decision Tree")
                }
            } detail: {
                if let node = selection {
                    NodeEditorView(node: node) { updated in
                        replaceNode(in: &root, with: updated)
                        // Update selection to reflect latest value from tree (id stable)
                        selection = findNode(in: root, id: updated.id)
                    }
                } else {
                    Text("Select a node")
                        .foregroundColor(.secondary)
                }
            }
            .navigationDestination(for: DecisionNode.self) { node in
                NodeEditorView(node: node)
            }
        } // NavigationStack
        // This binds the sidebar selection to the @State property
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
//        .onChange(of: selection) { newValue in
//            // Debug loggin
//            if let node = newValue {
//                print("Selected node: \(node.id)")
//            }
//        }
    }

    private func replaceNode(in node: inout DecisionNode, with updated: DecisionNode) {
        if node.id == updated.id {
            node = updated
            return
        }
        guard var branches = node.branches else { return }
        for (key, child) in branches {
            var mutableChild = child
            replaceNode(in: &mutableChild, with: updated)
            branches[key] = mutableChild
        }
        node.branches = branches
    }

    private func findNode(in node: DecisionNode, id: String) -> DecisionNode? {
        if node.id == id { return node }
        guard let branches = node.branches else { return nil }
        for (_, child) in branches {
            if let found = findNode(in: child, id: id) { return found }
        }
        return nil
    }
}

// Preview
#Preview {
    ContentView(root: .sampleTree)
}

