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
            // Question line: chevron + Q: + question text
            HStack(spacing: 6) {
                Button {
                    if hasChildren { toggle(node.id) }
                } label: {
                    Image(systemName: disclosureIconName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .opacity(hasChildren ? 1 : 0)
                        .frame(width: 14)
                }
                .buttonStyle(.plain)

                Button {
                    selection = node
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Q:")
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        NodeLabel(node: node)
                            .lineLimit(nil)
                    }
                    .contentShape(Rectangle())
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(selection?.id == node.id ? 0.12 : 0))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selection?.id == node.id ? Color.accentColor : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
            }

            // Children when expanded
            if isExpanded, let branches = node.branches {
                ForEach(branches, id: \.id) { child in
                    VStack(alignment: .leading, spacing: 4) {
                        // Answer line: A: <label>
                        HStack(spacing: 6) {
                            // indent for answers relative to the question chevron
                            Text("")
                                .frame(width: 14) // reserve space where a chevron would be
                            Button {
                                selection = child
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("A:")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                    Text(child.label)
                                        .fontWeight(.semibold)
                                }
                                .contentShape(Rectangle())
                                .padding(.leading, 0)
                            }
                            .buttonStyle(.plain)
                            Spacer(minLength: 0)
                        }
                        .padding(.leading, 12)

                        // Next line: either nested question (chevron + Q:) or result line starting with "-"
                        if isLeaf(child), let result = resultText(child) {
                            HStack(spacing: 6) {
                                Text("")
                                    .frame(width: 14)
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("-")
                                        .foregroundStyle(.secondary)
                                    Text(result)
                                }
                            }
                            .padding(.leading, 24)
                        } else {
                            // Show the child's question line with its own chevron and Q:
                            NodeListView(node: child, expanded: $expanded, selection: $selection)
                                .padding(.leading, 12)
                        }
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

    private func isLeaf(_ n: DecisionNode) -> Bool {
        if let branches = n.branches, !branches.isEmpty { return false }
        return (n.result?.isEmpty == false)
    }

    private func resultText(_ n: DecisionNode) -> String? {
        guard let text = n.result, !text.isEmpty else { return nil }
        return text
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
