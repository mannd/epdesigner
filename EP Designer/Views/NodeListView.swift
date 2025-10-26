//
//  NodeListView.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI

struct NodeListView: View {
    let node: DecisionNode
    @Binding var expanded: Set<String>
    @Binding var selection: DecisionNode?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                // Disclosure toggle
                Button {
                    if hasChildren {
                        toggle(node.id)
                    }
                } label: {
                    Image(systemName: disclosureIconName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .opacity(hasChildren ? 1 : 0)
                        .frame(width: 14)
                }
                .buttonStyle(.plain)

                // Selectable label
                Button {
                    selection = node
                } label: {
                    NodeLabel(node: node)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }

            // Render children only when expanded
            if isExpanded, let branches = node.branches {
                ForEach(branches.sorted(by: { $0.key < $1.key }), id: \.key) { key, child in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            // Indent for branch label
                            Text("\(key):")
                                .foregroundStyle(.secondary)
                                .padding(.leading, 12)

                            Button {
                                selection = child
                            } label: {
                                NodeLabel(node: child, prefix: key)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }

                        // Recurse for grandchildren (indent)
                        NodeListView(node: child, expanded: $expanded, selection: $selection)
                            .padding(.leading, 12)
                    }
                }
            }
        }
    }

    private var hasChildren: Bool { (node.branches?.isEmpty == false) }
    private var isExpanded: Bool { expanded.contains(node.id) }

    private func toggle(_ id: String) {
        if expanded.contains(id) {
            expanded.remove(id)
        } else {
            expanded.insert(id)
        }
    }

    private var disclosureIconName: String {
        guard hasChildren else { return "circle.fill" } // rendered clear when no children
        return isExpanded ? "chevron.down" : "chevron.right"
    }
}

#Preview {
    StatefulPreviewWrapper((Set<String>(), Optional<DecisionNode>.none)) { expanded, selection in
        NodeListView(node: DecisionNode.sampleTree, expanded: expanded, selection: selection)
            .padding()
    }
}

// MARK: - Preview helper
struct StatefulPreviewWrapper<Value1, Value2, Content: View>: View {
    @State private var value1: Value1
    @State private var value2: Value2
    let content: (Binding<Value1>, Binding<Value2>) -> Content

    init(_ initial: (Value1, Value2), @ViewBuilder content: @escaping (Binding<Value1>, Binding<Value2>) -> Content) {
        _value1 = State(initialValue: initial.0)
        _value2 = State(initialValue: initial.1)
        self.content = content
    }

    var body: some View { content($value1, $value2) }
}
