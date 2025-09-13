//
//  ContentView.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI

struct ContentView: View {
    let root: DecisionNode

    var body: some View {
        NavigationStack {
            NavigationSplitView {
                NodeListView(node: root)
                .navigationTitle("Decision Tree")
            } detail: {
                Text("Select a node")
                    .foregroundColor(.secondary)
            }
            // Attach the destination to the NavigationStack (works reliably)
            .navigationDestination(for: DecisionNode.self) { node in
                NodeDetailView(node: node)
            }
        } // NavigationStack
    }
}

// Preview
#Preview {
    ContentView(root: .sampleTree)
}
