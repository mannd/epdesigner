//
//  NodeListView.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI

struct NodeListView: View {
    let node: DecisionNode

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Make the node selectable
            NavigationLink(value: node) {
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
                        }
                        .padding(.leading, 12)

                        // Recurse for grandchildren (indent)
                        if child.branches != nil {
                            NodeListView(node: child)
                                .padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NodeListView(node: DecisionNode.sampleTree)
}
