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
    @State private var selectedNodeID: String? = nil

    var body: some View {
        NavigationStack {
            NavigationSplitView {
                // Sidebar
                ScrollView {
                    NodeListView(node: root, expanded: $expanded, selection: Binding<DecisionNode?>(
                        get: { selectedNodeID.flatMap { findNode(in: root, id: $0) } },
                        set: { selectedNodeID = $0?.id }
                    ))
                        .padding()
                        .navigationTitle("Decision Tree")
                }
            } detail: {
                if let id = selectedNodeID, let node = findNode(in: root, id: id) {
                    let nodeBinding = Binding<DecisionNode>(
                            get: {
                                // The getter returns the current value of 'node'
                                // This is needed for the initial display and subsequent reads
                                // within NodeEditorView.
                                // A more robust implementation might re-find the node in root
                                // if you expect root to change outside of this block.
                                return node // or better: findNode(in: root, id: id)!
                            },
                            set: { updatedNode in
                                // The setter is called when NodeEditorView tries to write a new value.
                                // This is where you perform your update logic.
                                replaceNode(in: &root, with: updatedNode)

                                // Keep the same selection id (stable)
                                selectedNodeID = updatedNode.id
                            }
                        )
                    NodeEditorView(node: nodeBinding) { updated in
                        replaceNode(in: &root, with: updated)
                        // Keep the same selection id (stable)
                        selectedNodeID = updated.id
                    }
                    .id(node.id)
                } else {
                    Text("Select a node")
                        .foregroundColor(.secondary)
                }
            }
            .navigationDestination(for: DecisionNode.self) { node in
                let nodeBinding = Binding<DecisionNode>(
                        get: {
                            // The getter returns the current value of 'node'
                            // This is needed for the initial display and subsequent reads
                            // within NodeEditorView.
                            // A more robust implementation might re-find the node in root
                            // if you expect root to change outside of this block.
                            return node // or better: findNode(in: root, id: id)!
                        },
                        set: { updatedNode in
                            // The setter is called when NodeEditorView tries to write a new value.
                            // This is where you perform your update logic.
                            replaceNode(in: &root, with: updatedNode)

                            // Keep the same selection id (stable)
                            selectedNodeID = updatedNode.id
                        }
                    )
                NodeEditorView(node: nodeBinding)
            }
        } // NavigationStack
        // This binds the sidebar selection to the @State property
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
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

