//
//  NodeDetailView.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI

struct NodeDetailView: View {
    let node: DecisionNode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Node Details")
                .font(.title2)
                .bold()

            if let question = node.question {
                Text("Question: \(question)")
            }

            if let branches = node.branches {
                Text("Branches: \(branches.keys.joined(separator: ", "))")
            } else {
                Text("No branches")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(node.question ?? "Node")
    }
}

#Preview {
    NodeDetailView(node: DecisionNode.sampleTree)
}
