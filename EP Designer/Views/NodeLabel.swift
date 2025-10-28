//
//  NodeLabel.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI

struct NodeLabel: View {
    let node: DecisionNode
    var prefix: String? = nil

    var body: some View {
        HStack {
            if let prefix = prefix {
                Text(prefix).bold()
            }
            Text(getLabel())
        }
    }

    private func getLabel() -> String {
        if node.isLeaf {
            return node.result ?? "Unknown Result"
        }
        return node.question ?? "Untitled Node"
    }
}

#Preview {
    NodeLabel(node: DecisionNode.sampleTree)
}

