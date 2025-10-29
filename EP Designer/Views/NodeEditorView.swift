import SwiftUI

struct NodeEditorView: View {
    @Binding var node: DecisionNode
    @State private var selectedChildID: String? = nil
    var onChange: (DecisionNode) -> Void

    init(node: Binding<DecisionNode>, onChange: @escaping (DecisionNode) -> Void = { _ in }) {
        self._node = node
        self.onChange = onChange
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { selectedChildID = nil }
            ScrollView {
                VStack(spacing: 24) {
                    // Node Header
                    HStack { Spacer(minLength: 0)
                        HStack(spacing: 8) {
                            Image(systemName: "square.grid.2x2")
                            Text("Node").font(.title3.weight(.semibold))
                        }
                        .frame(maxWidth: 640)
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 8)

                    // Node Card
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Label")
                                    .frame(width: 120, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                                TextField("Answer from parent, e.g. Blue", text: $node.label)
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Question")
                                    .frame(width: 120, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                                TextField(
                                    node.isLeaf ? "Question disabled for leaf nodes" : "What is your question?",
                                    text: Binding(
                                        get: { node.isLeaf ? "" : (node.question ?? "") },
                                        set: { newValue in
                                            if node.isLeaf {
                                                // Keep blank when leaf
                                                node.question = nil
                                            } else {
                                                node.question = newValue.isEmpty ? nil : newValue
                                            }
                                        }
                                    )
                                )
                                .disabled(node.isLeaf)
                                .accessibilityHint(node.isLeaf ? "Disabled for leaf nodes" : "Edit the question")
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Result (leaf)")
                                    .frame(width: 120, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                                TextField(
                                    (node.branches?.isEmpty == false) ? "Result disabled when branches exist" : "",
                                    text: Binding(
                                        get: { (node.branches?.isEmpty == false) ? (node.result ?? "") : (node.result ?? "") },
                                        set: { newValue in
                                            if node.branches?.isEmpty == false {
                                                // Ignore edits when branches exist
                                                return
                                            } else {
                                                node.result = newValue.isEmpty ? nil : newValue
                                            }
                                        }
                                    )
                                )
                                .disabled(node.branches?.isEmpty == false)
                                .accessibilityHint((node.branches?.isEmpty == false) ? "Disabled when branches exist" : "Enter a result to make this a leaf")
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Note")
                                    .frame(width: 120, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                                TextField("", text: Binding(
                                    get: { node.note ?? "" },
                                    set: { node.note = $0.isEmpty ? nil : $0 }
                                ))
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Tag")
                                    .frame(width: 120, alignment: .trailing)
                                    .foregroundStyle(.secondary)
                                TextField("", text: Binding(
                                    get: { node.tag ?? "" },
                                    set: { node.tag = $0.isEmpty ? nil : $0 }
                                ))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.secondary.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .frame(maxWidth: 640)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)

                    // Divider between sections
                    HStack { Spacer(minLength: 0)
                        Divider().frame(maxWidth: 640)
                        Spacer(minLength: 0) }

                    // Branches Header
                    HStack { Spacer(minLength: 0)
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.branch")
                            Text("Branches").font(.title3.weight(.semibold))
                        }
                        .frame(maxWidth: 640)
                        Spacer(minLength: 0)
                    }

                    // Branches Card
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .leading, spacing: 12) {
                            let children = node.branches ?? []
                            if children.isEmpty {
                                Text("No branches").foregroundStyle(.secondary)
                            } else {
                                ForEach(children, id: \.id) { child in
                                    HStack {
                                        Text(child.label).bold()
                                        Text(child.question ?? child.result ?? "Untitled")
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedChildID = child.id }
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.accentColor.opacity(selectedChildID == child.id ? 0.12 : 0))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedChildID == child.id ? Color.accentColor : Color.clear, lineWidth: 1)
                                    )
                                    .contextMenu {
                                        Button(role: .destructive) { removeBranch(child.label) } label: {
                                            Label("Delete Branch", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            Button { addBranch() } label: { Label("Add Branch", systemImage: "plus") }
                            .disabled(node.isLeaf)
                            .accessibilityHint(node.isLeaf ? "Disabled for leaf nodes" : "Add a new branch")

                            // Contextual messages
                            if node.branches?.isEmpty == false {
                                // There are branches; explain why Result is disabled
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.secondary)
                                    Text("This node has branches. Delete all branches before setting a Result. A node cannot be a leaf and have branches at the same time.")
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.secondary.opacity(0.08))
                                )
                            }

                            if node.isLeaf {
                                // It's a leaf; explain why Question is disabled
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.secondary)
                                    Text("This is a leaf node (has a Result). The Question field is disabled for leaf nodes.")
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.secondary.opacity(0.08))
                                )
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.secondary.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .frame(maxWidth: 640)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(node.question ?? "Node Details")
    }

    private func addBranch() {
        let base = "New Branch"
        var label = base
        var i = 1
        var children = node.branches ?? []
        while children.contains(where: { $0.label == label }) {
            i += 1
            label = "\(base) \(i)"
        }
        let newChild = DecisionNode(label: label, question: "New question")
        children.append(newChild)
        node.branches = children
    }

    private func removeBranch(_ label: String) {
        guard var children = node.branches else { return }
        children.removeAll { $0.label == label }
        node.branches = children.isEmpty ? nil : children
    }
}

#Preview {
    NavigationStack {
        NodeEditorView(node: .constant(.sampleTree)) { _ in }
    }
}
